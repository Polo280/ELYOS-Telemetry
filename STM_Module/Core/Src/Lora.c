#include <Lora.h>
#include <string.h>

// SPI Handler
SPI_HandleTypeDef *spi_handler;

// Data buffer for SPI communication
uint8_t data_buffer [2];

// Default initialization parameters
LoraConfigStruct defaultConfigStruct= {
    .spi_port = LORA_DEFAULT_SPI_PORT,
    .nss_port = LORA_DEFAULT_NSS_PORT,
    .rst_port = LORA_DEFAULT_RST_PORT,
    .mosi_pin = LORA_DEFAULT_MOSI_PIN,
    .miso_pin = LORA_DEFAULT_MISO_PIN,
    .nss_pin = LORA_DEFAULT_NSS_PIN,
    .sck_pin = LORA_DEFAULT_SCK_PIN,
    .rst_pin = LORA_DEFAULT_RST_PIN,
	.freq =    LORA_DEFAULT_FREQUENCY
};

// Custom Initialization parameters
LoraConfigStruct *loraConfigStruct;

void LoraGPIOsConfig(LoraConfigStruct *configStruct){
    // NOTE: This function assumes you have previously enabled port RCC clock from the GPIOs used with LoRa Module
    // Initialization of SPI channels
	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();

    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = configStruct->miso_pin | configStruct->mosi_pin | configStruct->sck_pin;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    HAL_GPIO_Init(configStruct->spi_port, &GPIO_InitStruct);

    // Initialization of NSS line
    GPIO_InitStruct.Pin = configStruct->nss_pin;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;

    HAL_GPIO_Init(configStruct->nss_port, &GPIO_InitStruct);

    // This thing causing all the errors in GPS interrupt (seems like it shares resources with usart1)
    // Initialization of RST Line
    GPIO_InitStruct.Pin = configStruct->rst_pin;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(configStruct->rst_port, &GPIO_InitStruct);
}

// Intialize Lora module with default values
uint8_t LoraDefaultInit(void){
	loraConfigStruct = &defaultConfigStruct;
    return LoraInit(&defaultConfigStruct);
}

uint8_t LoraInit(LoraConfigStruct *loraConfig){
    // Configure GPIOS
    LoraGPIOsConfig(loraConfig);  // Uncomment if you havent already configured your pins

    // Hardware Reset  (Optional but recommended)
    HAL_GPIO_WritePin(loraConfig->rst_port, loraConfig->rst_pin, GPIO_PIN_SET);  // RESET IS LOW OR HIGH?
    HAL_Delay(50);
    HAL_GPIO_WritePin(loraConfig->rst_port, loraConfig->rst_pin, GPIO_PIN_RESET);
    HAL_Delay(50);
    HAL_GPIO_WritePin(loraConfig->rst_port, loraConfig->rst_pin, GPIO_PIN_SET);
    HAL_Delay(25);

    // Set NSS to high (not communicating with module currently)
    HAL_GPIO_WritePin(loraConfig->nss_port, loraConfig->nss_pin, GPIO_PIN_SET);

    // Begin SPI communication in specified handler
    if(HAL_SPI_Init(spi_handler) != HAL_OK){
        return LORA_NOT_OK;
    }

    // Get and verify LoRa version
    if(GetLoraVersion() == 0){
    	return LORA_NOT_OK;  // Error
    }

    // Set to sleep to modify freq and other values
    LoraSleep();
    // Set Lora frequency
    LoraSetFrequency(loraConfig->freq);

    // Configure RX and TX FIFOs
    LoraWriteRegister(REG_FIFO_TX_BASE_ADDR, 0);
    LoraWriteRegister(REG_FIFO_RX_BASE_ADDR, 0);

    // set LNA boost
    LoraWriteRegister(REG_LNA, LoraReadRegister(REG_LNA) | 0x03);
    // set auto AGC
    LoraWriteRegister(REG_MODEM_CONFIG_3, 0x04);
    // Set transmission power
    LoraSetTxPower(17, PA_BOOST_MODE);

    LoraSetIdle();
    return LORA_OK;
}

// Function to set a previously configured SPI handler (USE IT BEFORE ANY OTHER FUNCTION)
void LoraSetSPIHandler(SPI_HandleTypeDef *hspi){
    spi_handler = hspi;
}

// Function to send some address and a data byte to the module
uint8_t LoraSendSPI(uint8_t address, uint8_t value, LoraConfigStruct *loraConfig){
    uint8_t response = 0;

    HAL_GPIO_WritePin(loraConfig->nss_port, loraConfig->nss_pin, GPIO_PIN_RESET);          // Set to low the nss line to enable module for sending data to it
    if(HAL_SPI_Transmit(spi_handler, &address, 1, SPI_TRANSMIT_TIMEOUT)!= HAL_OK){return LORA_NOT_OK;}                   // Send the address
    if(HAL_SPI_TransmitReceive(spi_handler, &value, &response, 1, SPI_TRANSMIT_TIMEOUT) != HAL_OK){return LORA_NOT_OK;}    // The 1 is the number of bytes you want to transmit
    HAL_GPIO_WritePin(loraConfig->nss_port, loraConfig->nss_pin, GPIO_PIN_SET);        // Set nss line low to disable
    return response;
}

// Function to read registers from LoRa module
uint8_t LoraReadRegister(uint8_t address){
    return LoraSendSPI(address & 0x7f, 0x00, loraConfigStruct);
}

// Function to write data to registers
void LoraWriteRegister(uint8_t address, uint8_t value){
    LoraSendSPI(address | 0x80, value, loraConfigStruct);
}

/////////////////////// FUNCTIONS USING REGISTER FUNCTIONALITY ///////////////////////

// Use this to send data over RF, just pass the buffer containing characters as parameter
void LoraSendRF(const char* buffer){
	LoraBeginPacket(0);
	LoraTransmit(buffer);
	LoraEndPacket(0);
}

// Prepare to transmit
void LoraTransmit(const char* buffer){
	LoraWrite((uint8_t *)buffer, strlen(buffer));
}

// Function to actually transmit the data
void LoraWrite(const uint8_t *buffer, size_t size)  // Size_t is the same as unsigned long
{
  int currentLength = LoraReadRegister(REG_PAYLOAD_LENGTH);

  // Ensure total size is less than packet max allowed length
  if ((currentLength + size) > MAX_PKT_LENGTH) {
    size = MAX_PKT_LENGTH - currentLength;
  }

  // write data
  for (size_t i = 0; i < size; i++) {
    LoraWriteRegister(REG_FIFO, buffer[i]);
  }

  // update length
  LoraWriteRegister(REG_PAYLOAD_LENGTH, currentLength + size);
}

// Function to get the version of the LoRa module
uint8_t GetLoraVersion(void){
    return LoraReadRegister(REG_VERSION);
}

uint8_t LoraGetRXBytes(void){
	return LoraReadRegister(REG_RX_NB_BYTES);
}

// Expecting 915 MHz frequency (915E6)
void LoraSetFrequency(uint64_t frequency){  				// Configure FRF (Frequency Synthesis Register)
	uint64_t frf = ((uint64_t)frequency << 19) / 32000000;  // Given by datasheet formula
	LoraWriteRegister(REG_FRF_MSB, (uint8_t)(frf >> 16));
	LoraWriteRegister(REG_FRF_MID, (uint8_t)(frf >> 8));
	LoraWriteRegister(REG_FRF_LSB, (uint8_t)(frf >> 0));
}

// Configure packet format before sending
uint8_t LoraBeginPacket(uint8_t isImplicitHeader){   // Explicit header messages contain a header for detecting errors, implicits dont
	if(IsTransmitting() == 1){
		return 0;
	}

	// Set in idle (sleep but with internal oscillators enabled)
	LoraSetIdle();

	// Handle implicit and explicit headers
	if(isImplicitHeader == 1){
		LoraWriteRegister(REG_MODEM_CONFIG_1, LoraReadRegister(REG_MODEM_CONFIG_1) | 0x01);
	}else if(isImplicitHeader == 0){
		LoraWriteRegister(REG_MODEM_CONFIG_1, LoraReadRegister(REG_MODEM_CONFIG_1) & 0xfe);
	}

	// reset FIFO address and payload length
    LoraWriteRegister(REG_FIFO_ADDR_PTR, 0);
    LoraWriteRegister(REG_PAYLOAD_LENGTH, 0);
    return 1;
}

uint8_t LoraEndPacket(uint8_t sync){
	// For now, only synchronous (wait for transmission completed by polling) tx is supported
	  LoraWriteRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_TX);   // Enable TX mode

	  while ((LoraReadRegister(REG_IRQ_FLAGS) & IRQ_TX_DONE_MASK) == 0) {
	        HAL_Delay(1);
	  }
	  // clear IRQ's
	  LoraWriteRegister(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK);
	  return 0;
}

uint8_t LoraGetSpreadingFactor(void){
	return LoraReadRegister(REG_MODEM_CONFIG_2) >> 4;
}

// Function to check if module is currently transmitting info
uint8_t IsTransmitting(void){
	if ((LoraReadRegister(REG_OP_MODE) & MODE_TX) == MODE_TX) {
	    return 1;
	}

	if (LoraReadRegister(REG_IRQ_FLAGS) & IRQ_TX_DONE_MASK) {
	  // clear IRQ's
	  LoraWriteRegister(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK);
	}
	return 0;
}

// Set OverCurrent Protection
void LoraSetOCP(uint8_t milliAmps){
	uint8_t OCP_Trim = 27;   // 27 allows for maximum safe current protection (240 mA)

	// Adjust according to datasheet formula
	if (milliAmps <= 120) {
		OCP_Trim = (milliAmps - 45) / 5;
	} else if (milliAmps <= 240) {
	    OCP_Trim = (milliAmps + 30) / 10;
	}
	LoraWriteRegister(REG_OCP, 0x20 | (0x1F & OCP_Trim));
}

// Set transmission power (mode is used as a boolean, where 0 means RFO = Low power applications and 1 means PA_BOOST used for higher power applications
void LoraSetTxPower(uint8_t level, uint8_t mode){
	if(mode == RFO_MODE){
		// Bound level
		if(level < 0){
			level = 0;
		}else if(level > 14){
			level = 14;
		}
		LoraWriteRegister(REG_PA_CONFIG, 0x70 | level);
	}else{
		// PA_BOOST_MODE
		if (level > 17) {
		   if (level > 20) {
		      level = 20;
		   }
		   // subtract 3 from level, so 18 - 20 maps to 15 - 17
		   level -= 3;
		   // High Power +20 dBm Operation (Semtech SX1276/77/78/79 5.4.3.)
		   LoraWriteRegister(REG_PA_DAC, 0x87);
		   LoraSetOCP(140);
		}else {
	      if (level < 2) {
	        level = 2;
	      }
	      //Default value PA_HF/LF or +17dBm
	      LoraWriteRegister(REG_PA_DAC, 0x84);
	      LoraSetOCP(100);
	    }
		LoraWriteRegister(REG_PA_CONFIG, PA_BOOST | (level - 2));
	}
}

// Set Lora Module to IDLE mode
void LoraSetIdle(void){
    LoraWriteRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY);
}

// Set Lora to sleep mode
void LoraSleep(void){
   LoraWriteRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_SLEEP);
}

// Put the Lora module to sleep if not needed anymore
void LoraEnd(void){
	LoraSleep();
}
