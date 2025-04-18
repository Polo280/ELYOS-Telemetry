#include "main.h"

// Power Constants
const float CURRENT_SENSE_MAX_AMPS = 3.3 / (CURRENT_SENSE_GAIN * SHUNT_RESISTOR_VALUE); // 338

// Time control
uint32_t power_aux = 0;
uint32_t lora_aux = 0;
uint32_t gps_aux = 0;
uint32_t imu_aux = 0;
uint32_t uart_aux = 0;
uint32_t blink_aux = 0;
uint32_t kalman_aux = 0;
uint32_t rpm_pulse_timestamp = 0;
uint32_t rpm_calculation_aux = 0;

// Power measurements
float battery_voltage = 0.0;
float current_amps = 0.0;
float previous_amps = 0.0;
float current_samples[MOVING_AVG_WINDOW];  // Filter for current sensing
uint8_t sample_index = 0;
float current_sum = 0;

// IMU
bno055_euler_t gyro_euler;
bno055_acc_t accel_data;

// GPS
GPS_DATA gps_data;     // Store GPS info
char gps_received;     // New byte rx
char gps_buffer[512];  // Received buffer
volatile uint32_t gps_buffer_index = 0; // Received buffer current index
char nmea_sentences [MAX_SENTENCES_SPLIT][MAX_SENTENCE_LENGTH]; // NMEA Sentence store

// RPM calculation
volatile uint32_t total_rpms = 0;
uint32_t rev_counter = 0;
uint16_t rpms = 0;

// Kalman Filter
KalmanFusion kalman_filter;
float ref_latitude = 0.0;  // Reference start coordinates
float ref_longitude = 0.0;
float32_t accel_inputs[3];
float32_t observed_state_GPS[6];
float32_t Zk_data[STATE_SPACE_VECTOR_ROWS] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
arm_matrix_instance_f32 Zk;

// Control variables
uint8_t invalid_imu_samples = 0;

// Transmit telemetry buffer
char tx_buff[256];


int main(void)
{
  telemetryInit();

  while (1)
  {
	  // Refresh
	  //HAL_IWDG_Refresh(&hiwdg);

	  // IMU communication validation
	  if(invalid_imu_samples >= MAX_INVALID_IMU_SAMPLES){
		  __disable_irq();
		  NVIC_SystemReset();
	  }

	  // Voltage and current
	  if(HAL_GetTick() - power_aux >= TIME_TO_SAMPLE_POWER){
	      readADCValues();
		  power_aux = HAL_GetTick();
	  }

	  // Measure IMU
	  if(HAL_GetTick() - imu_aux >= TIME_TO_READ_IMU){
		  bno055_read_euler_hrp(&gyro_euler);
		  bno055_read_acc_xyz(&accel_data);
		  invalid_imu_samples = (accel_data.z == 0)? invalid_imu_samples + 1 : 0;  // Check data integrity
		  imu_aux = HAL_GetTick();
	   }

	   // Parse GPS buffer
	   if(HAL_GetTick() - gps_aux >= TIME_TO_PARSE_GPS){
		   processGPS();
		   store_GPS_ObservedState();  // Update Kalman
		   gps_aux = HAL_GetTick();
	   }

	   // Calculate RPMs
	   if(HAL_GetTick() - rpm_calculation_aux >= RPM_DELTA_T_MILLIS){
		   calculateRPMs();
		   rpm_calculation_aux = HAL_GetTick();
	   }

	   // Kalman Predict
	   if(HAL_GetTick() - kalman_aux >= KALMAN_DELTA_T){
		   // Set control inputs array
		   accel_inputs[0] = accel_data.x;
		   accel_inputs[1] = accel_data.y;
		   accel_inputs[2] = accel_data.z;
		   // Predict every delta t
		   KF_Predict(&kalman_filter, accel_inputs);
		   KF_Update(&kalman_filter, &Zk);
		   kalman_aux = HAL_GetTick();
	   }

	   // Construct string and send data over RF
	   if(HAL_GetTick() - lora_aux >= TIME_TO_SEND_LORA){
		   buildPacketRF();
		   lora_aux = HAL_GetTick();
	   }

	  // Debug
	  if(HAL_GetTick() - uart_aux >= TIME_TO_PRINT_UART){
		// HAL_UART_Transmit(&huart2, (uint8_t*)tx_buff, sizeof(tx_buff), 100);
		uart_aux = HAL_GetTick();
	  }

	  // LED Toggle
	  if(HAL_GetTick() - blink_aux >= TIME_TO_BLINK){
		  HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_1);
		  blink_aux = HAL_GetTick();
	  }
  }
}


void telemetryInit(void){
  HAL_Init();
  SystemClock_Config();

  // Peripherals
  MX_GPIO_Init();
  MX_ADC1_Init();
  MX_I2C1_Init();
  MX_SPI3_Init();
  MX_USART1_UART_Init();
  MX_USART2_UART_Init();

  // IMU
  IMU_Config();

  // Lora
  LoraConfig();

  // Kalman Configuration
  KF_Init(&kalman_filter);
  arm_mat_init_f32(&Zk, STATE_SPACE_VECTOR_ROWS, 1, Zk_data);

  // GPS Interrupt Enable
  configure_GPS_Interrupt();

  // Configure interrupt for Hall sensor (RPMs)
  RPM_InterruptConfig();

  // Independent Watchdog
  //MX_IWDG_Init();
}


void IMU_Config(void){
	bno055_set_i2c_handler(&hi2c1);
	bno055_init(&default_bno055_config, &default_bno055_verification);
}


void LoraConfig(void){
	// IMPORTANT: Desolder SB18 bridge from the bottom of NUCLEO L432KC, otherwise RST (PA5) will interfere with GPS interrupt
	LoraSetSPIHandler(&hspi3);
	if(LoraDefaultInit() != LORA_OK){
		Error_Handler();
	}
}


void RPM_InterruptConfig(void){
	HAL_NVIC_SetPriority(EXTI1_IRQn, 0, 0);
	HAL_NVIC_EnableIRQ(EXTI1_IRQn);
}


void configure_GPS_Interrupt(void){
    // USART GPS Interrupt configuration
    USART1->CR1 |= USART_CR1_RE;      // Enable receiver mode
    USART1->CR1 |= USART_CR1_RXNEIE;  // Enable RXNE interrupt
    HAL_NVIC_SetPriority(USART1_IRQn, 0, 0);
    HAL_NVIC_EnableIRQ(USART1_IRQn);
}


void USART1_IRQHandler(void){
    // Clear blocking errors
	if (USART1->ISR & USART_ISR_ORE) {    // Overrun Error
		USART1->ICR |= USART_ICR_ORECF;
	}
	if (USART1->ISR & USART_ISR_FE) {     // Framing Error
		USART1->ICR |= USART_ICR_FECF;
	}
	if (USART1->ISR & USART_ISR_NE) {     // Noise Error
		USART1->ICR |= USART_ICR_NCF;
	}
	if (USART1->ISR & USART_ISR_PE) {	  // Parity Error
		USART1->ICR |= USART_ICR_PECF;
	}

  // Check if RX interrupt flag is set
  if(USART1->ISR & (1 << 5)){
	  // Read received byte
	  gps_received = USART1->RDR;
	  // Check index for overflow
	  if(gps_buffer_index >= sizeof(gps_buffer) - 1){
		  gps_buffer[sizeof(gps_buffer) - 1] = '\0';
		  gps_buffer_index = 0;
	  }
	  *(gps_buffer + gps_buffer_index) = gps_received;
	  gps_buffer_index ++;
  }
}


void processGPS(void){
	splitNMEASentences(gps_buffer, nmea_sentences);
	uint8_t valid_found = 0;
	// First sentence generally is trash
	for(uint8_t i=1; i < MAX_SENTENCES_SPLIT; i++){
		// Only parse valid sentences
		if(nmea_sentences[i][0] != '\0') {
			parseGPSData(nmea_sentences[i], &gps_data);
			valid_found = 1;
		}
	}
	// Set to invalid status if nothing was received
	if(!valid_found){
		gps_data.GPRMC_data.status = 'X';
	}
}


void store_GPS_ObservedState(void){
	// Check if sentence is valid
	if(gps_data.GPRMC_data.status != 'A'){
		return;
	}

	// Check if a reference point has already been set
	if(ref_latitude == 0.0 || ref_longitude == 0.0){
		ref_latitude = gps_data.GPRMC_data.latitude;
		ref_longitude = gps_data.GPRMC_data.longitude;
		return;
	}

	// Relative position
	float x = 0.0, vx = 0.0, y = 0.0, vy = 0.0;
	latlon_to_xy(ref_latitude, ref_longitude,gps_data.GPRMC_data.latitude,
				 gps_data.GPRMC_data.longitude, &x, &y);
	// Velocity
	get_GPS_VelocityComponents(gps_data.GPRMC_data.speed_knots, gps_data.GPRMC_data.track_angle, &vx, &vy);

	// Set error covariance and measurement matrix
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		kalman_filter.R_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 0.1;
		if(i < 4){
			kalman_filter.H_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] =  1;
		}else{
			kalman_filter.H_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 0;
		}
	}

	// Prepare Zk measurement
	Zk_data[0] = x;
	Zk_data[1] = vx;
	Zk_data[2] = y;
	Zk_data[3] = vy;
	Zk_data[4] = 0.0;
	Zk_data[5] = 0.0;

	// Update!
	KF_Update(&kalman_filter, &Zk);
}


void readADCValues(void) {
    uint16_t adc_val = 0;

    // Read raw ADC value from channel
    adc_val = pollFromChannelADC(CURRENT_SAMPLE_ADC_CHANNEL);

    // Convert to amps (not filtered yet)
    float aux_amps = adc_val * ADC_TO_CURRENT * 2;

    // Update moving average buffer
    current_sum -= current_samples[sample_index];
    current_samples[sample_index] = aux_amps;
    current_sum += aux_amps;

    sample_index = (sample_index + 1) % MOVING_AVG_WINDOW;
    float avg_current = current_sum / MOVING_AVG_WINDOW;

    // Only assign if above threshold
    if (avg_current >= 0.01f) {
        current_amps = avg_current;
    }

	// Voltage calculation
	adc_val = pollFromChannelADC(VOLTAGE_SAMPLE_ADC_CHANNEL);
	battery_voltage = adc_val * MAX_ALLOWED_VOLTAGE / MAX_ADC_READING;
}


void EXTI1_IRQHandler(void){
	// If rising edge interrupt is detected
	if(EXTI->PR1 & EXTI_PR1_PIF1){
		if(HAL_GetTick() - rpm_pulse_timestamp >= NEW_REV_DEBOUNCE_TIME){
			total_rpms ++;
			rev_counter ++;
			EXTI->PR1 |= EXTI_PR1_PIF1;  // Clear interrupt flag
			rpm_pulse_timestamp = HAL_GetTick();
		}
	}
}


void calculateRPMs(void){
	rpms = rev_counter * (MINUTE_TO_MILLIS / (RPM_DELTA_T_MILLIS * NUMBER_OF_MAGNETS));
	rev_counter = 0;
}


void buildPacketRF(void){
  /*
   * CURRENT FORMAT (COMMA SEPARATED)
   * 1) Current in amps (float)
   * 2) Battery voltage (float)
   * 3,4,5) Accelerometer readings (m/s²)(float)
   * 6,7,8) Gyro readings euler (°)(float)
   * 9,10) Latitude, longitude
   * 11) Number of satellites connected
   * 12) GPS Status character (A | V)
   * 13) RPMs
  */
  snprintf(tx_buff, sizeof(tx_buff), "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.6f,%.6f,%d,%c,%d,%lu\n",
  current_amps, battery_voltage, accel_data.x, accel_data.y, accel_data.z,
  gyro_euler.h, gyro_euler.r, gyro_euler.p, gps_data.GPRMC_data.latitude, gps_data.GPRMC_data.longitude,
  gps_data.GPGGA_data.sat_count,gps_data.GPRMC_data.status, rpms, total_rpms);

//  snprintf(tx_buff, sizeof(tx_buff), "x:%f, vx:%f, y:%f, vy:%f\n", kalman_filter.x_hat_prev_data[0],
//		   kalman_filter.x_hat_prev_data[1], kalman_filter.x_hat_prev_data[2], kalman_filter.x_hat_prev_data[3]);

  transmitTelemetry();
}


void transmitTelemetry(void){
  // Tansmit the buffer
  LoraBeginPacket(0);
  LoraTransmit((char*)tx_buff);
  LoraEndPacket(0);
}


void Error_Handler(void)
{
  __disable_irq();
  while (1)
    {
  	  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, GPIO_PIN_SET);
    }
}
