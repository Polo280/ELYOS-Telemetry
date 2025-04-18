#ifndef __MAIN_H
#define __MAIN_H

#include "stm32l4xx_hal.h"
#include <stdio.h>
#include <string.h>
// Peripherals
#include "clocks.h"
#include "adc.h"
#include "i2c.h"
#include "iwdg.h"
#include "spi.h"
#include "usart.h"
#include "gpio.h"

// Custom libraries
#include "KalmanFilter.h"
#include "NMEA_Parser.h"
#include "BNO055.h"
#include "Lora.h"
#include "Conversions.h"

// Vehicle properties
#define MAX_ADC_READING        (float) 4095
#define VOLTAGE_DIVIDER_FACTOR (float) 0.1194  // R2 / (R1 + R2)
#define MAX_ALLOWED_VOLTAGE    (float) 32.0    // Maximum without saturating
#define CURRENT_SENSE_GAIN     (float) 20.0
#define SHUNT_RESISTOR_VALUE   (float) 0.007   // Adjust depending on shunt value
//MAX current in amps
#define MAX_MEASURABLE_CURRENT (float) 3.3 / (SHUNT_RESISTOR_VALUE * CURRENT_SENSE_GAIN)
								//I  //adc res
#define ADC_TO_CURRENT (float)  (3.3/(SHUNT_RESISTOR_VALUE*CURRENT_SENSE_GAIN))/4095
//corriente = voltaje/resistencia. resistencia = resistencia OG * amplificación de caida de voltaje
// si la corriente pasa de 23.5 amps, el amplificador se satura a 3.3v
// IIR Filter
#define IIR_ALPHA              (float)0.3

// Time control
#define TIME_TO_SAMPLE_POWER     1
#define TIME_TO_READ_IMU 	     10
#define TIME_TO_PARSE_GPS        1500
#define TIME_TO_SEND_LORA        500
#define TIME_TO_BLINK 		     1000
#define TIME_TO_PRINT_UART       500      // DEBUG
#define MOVING_AVG_WINDOW		 64


// RPMs
#define NUMBER_OF_MAGNETS 		 1        // Attached to the wheel
#define MINUTE_TO_MILLIS    	 60000.0
#define RPM_DELTA_T_MILLIS       3000.0
#define NEW_REV_DEBOUNCE_TIME    25

// ADC Settings
#define ADC1_RANGE (float)(1 << 12)
#define CURRENT_SAMPLE_ADC_CHANNEL ADC_CHANNEL_12
#define VOLTAGE_SAMPLE_ADC_CHANNEL ADC_CHANNEL_5

// GPS Parser
#define MAX_SENTENCES_SPLIT 4
#define MAX_SENTENCE_LENGTH 100
// IMU
#define MAX_INVALID_IMU_SAMPLES 10

// Kalman
#define KALMAN_DELTA_T KALMAN_DELTA_T_SECS * 1000   // Milliseconds

// Functions
extern void telemetryInit(void);
extern void KalmanFilterInit(void);
extern void IMU_Config(void);
extern void LoraConfig(void);
extern void buildPacketRF(void);
extern void readADCValues(void);
extern void configure_GPS_Interrupt(void);
extern void processGPS(void);
extern void store_GPS_ObservedState(void);
extern void RPM_InterruptConfig(void);
extern void calculateRPMs(void);
extern void GPS_interruptHandler(void);
extern void transmitTelemetry(void);

extern void Error_Handler(void);


// Constants
// Max ADC reading obtained at max battery capacity with current voltage divider resistor values considering ADC resolution bit number
extern const float MAX_BATTERY_ADC_READING;
// Max amps read at voltage level 3.3V with current shunt value
extern const float CURRENT_SENSE_MAX_AMPS;


// Time variables
extern uint32_t power_aux;
extern uint32_t uart_aux;
extern uint32_t lora_aux;
extern uint32_t imu_aux;
extern uint32_t blink_aux;
extern uint32_t kalman_aux;
extern uint32_t gps_aux;
extern uint32_t rpm_pulse_timestamp;

// Measurements
extern float battery_voltage;
extern float current_amps;
extern float previous_amps;
extern float current_samples[MOVING_AVG_WINDOW];
extern uint8_t sample_index;
extern float current_sum;

// IMU
extern bno055_euler_t gyro_euler;
extern bno055_acc_t accel_data;

// GPS
extern GPS_DATA gps_data;     // Store GPS info
extern char gps_received;     // New byte rx
extern char gps_buffer[512];  // Received buffer
extern volatile uint32_t gps_buffer_index; // Received buffer current index
extern char nmea_sentences [MAX_SENTENCES_SPLIT][MAX_SENTENCE_LENGTH]; // NMEA Sentence store

// RPM calculation
extern volatile uint32_t total_rpms;
extern uint32_t rev_counter;
extern uint16_t rpms;

// Kalman Filter
extern KalmanFusion kalman_filter;
extern float ref_latitude;
extern float ref_longitude;
extern float32_t accel_inputs[3];
extern float32_t observed_state_GPS[6];
extern float32_t Zk_data[STATE_SPACE_VECTOR_ROWS];
extern arm_matrix_instance_f32 Zk;

// Control variables
extern uint8_t invalid_imu_samples;

// Console print
extern char tx_buff[256];


#endif /* __MAIN_H */
