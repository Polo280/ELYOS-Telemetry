#ifndef INC_LORA_H_
#define INC_LORA_H_

#ifdef __cplusplus
extern "C"{
#endif

/////////// DEFINITIONS ///////////
// #define BLUEPILL
#define ELYOS_TELEMETRY_L432KC

// PINOUT
#ifdef BLUEPILL
	#define LORA_DEFAULT_SPI_PORT GPIOB
	#define LORA_DEFAULT_NSS_PORT GPIOA
	#define LORA_DEFAULT_RST_PORT GPIOA
	#define LORA_DEFAULT_MOSI_PIN GPIO_PIN_5
	#define LORA_DEFAULT_MISO_PIN GPIO_PIN_4
	#define LORA_DEFAULT_SCK_PIN  GPIO_PIN_3
	#define LORA_DEFAULT_NSS_PIN  GPIO_PIN_15
	#define LORA_DEFAULT_RST_PIN  GPIO_PIN_12
#elif defined(NUCLEO_F303RE)
	#define LORA_DEFAULT_SPI_PORT GPIOA
	#define LORA_DEFAULT_NSS_PORT GPIOB
	#define LORA_DEFAULT_RST_PORT GPIOC
	#define LORA_DEFAULT_MOSI_PIN GPIO_PIN_7
	#define LORA_DEFAULT_MISO_PIN GPIO_PIN_6
	#define LORA_DEFAULT_SCK_PIN  GPIO_PIN_5
	#define LORA_DEFAULT_NSS_PIN  GPIO_PIN_6
	#define LORA_DEFAULT_RST_PIN  GPIO_PIN_7
#elif defined(ELYOS_TELEMETRY_L432KC)
	#include "stm32l4xx_hal.h"
	#define LORA_DEFAULT_SPI_PORT GPIOB
	#define LORA_DEFAULT_NSS_PORT GPIOA
	#define LORA_DEFAULT_RST_PORT GPIOA
	#define LORA_DEFAULT_MOSI_PIN GPIO_PIN_5
	#define LORA_DEFAULT_MISO_PIN GPIO_PIN_4
	#define LORA_DEFAULT_SCK_PIN  GPIO_PIN_3
	#define LORA_DEFAULT_NSS_PIN  GPIO_PIN_4
	#define LORA_DEFAULT_RST_PIN  GPIO_PIN_5
#endif

// SPI SETTINGS MACROS
#define LORA_DEFAULT_FREQUENCY     915000000
#define SPI_TRANSMIT_TIMEOUT       100
#define SPI_RECEIVE_TIMEOUT        100

// LoRa Registers
#define REG_FIFO                 0x00
#define REG_OP_MODE              0x01
#define REG_FRF_MSB              0x06
#define REG_FRF_MID              0x07
#define REG_FRF_LSB              0x08
#define REG_PA_CONFIG            0x09
#define REG_OCP                  0x0b
#define REG_LNA                  0x0c
#define REG_FIFO_ADDR_PTR        0x0d
#define REG_FIFO_TX_BASE_ADDR    0x0e
#define REG_FIFO_RX_BASE_ADDR    0x0f
#define REG_FIFO_RX_CURRENT_ADDR 0x10
#define REG_IRQ_FLAGS            0x12
#define REG_RX_NB_BYTES          0x13
#define REG_PKT_SNR_VALUE        0x19
#define REG_PKT_RSSI_VALUE       0x1a
#define REG_RSSI_VALUE           0x1b
#define REG_MODEM_CONFIG_1       0x1d
#define REG_MODEM_CONFIG_2       0x1e
#define REG_PREAMBLE_MSB         0x20
#define REG_PREAMBLE_LSB         0x21
#define REG_PAYLOAD_LENGTH       0x22
#define REG_MODEM_CONFIG_3       0x26
#define REG_FREQ_ERROR_MSB       0x28
#define REG_FREQ_ERROR_MID       0x29
#define REG_FREQ_ERROR_LSB       0x2a
#define REG_RSSI_WIDEBAND        0x2c
#define REG_DETECTION_OPTIMIZE   0x31
#define REG_INVERTIQ             0x33
#define REG_DETECTION_THRESHOLD  0x37
#define REG_SYNC_WORD            0x39
#define REG_INVERTIQ2            0x3b
#define REG_DIO_MAPPING_1        0x40
#define REG_VERSION              0x42
#define REG_PA_DAC               0x4d

// modes
#define MODE_LONG_RANGE_MODE     0x80
#define MODE_SLEEP               0x00
#define MODE_STDBY               0x01
#define MODE_TX                  0x03
#define MODE_RX_CONTINUOUS       0x05
#define MODE_RX_SINGLE           0x06
#define MODE_CAD                 0x07

// PA config
#define PA_BOOST                 0x80

// IRQ masks
#define IRQ_TX_DONE_MASK           0x08
#define IRQ_PAYLOAD_CRC_ERROR_MASK 0x20
#define IRQ_RX_DONE_MASK           0x40
#define IRQ_CAD_DONE_MASK          0x04
#define IRQ_CAD_DETECTED_MASK      0x01

#define RF_MID_BAND_THRESHOLD    525E6
#define RSSI_OFFSET_HF_PORT      157
#define RSSI_OFFSET_LF_PORT      164

#define MAX_PKT_LENGTH           255

// Transmission Power
#define RFO_MODE                 0
#define PA_BOOST_MODE            1

// Debugging
#define LORA_OK                  0
#define LORA_NOT_OK              1

//////////// STRUCTS ////////////
// Default settings
typedef struct {
    GPIO_TypeDef      *spi_port;
    GPIO_TypeDef      *nss_port;   // Is the only channel that can be in a different port in bluepill
	GPIO_TypeDef      *rst_port;
    uint16_t mosi_pin;
	uint16_t miso_pin;
	uint16_t sck_pin;
	uint16_t nss_pin;
    uint16_t rst_pin;
    uint64_t freq;

} LoraConfigStruct;

/////////// FUNCTIONS ///////////
void LoraGPIOsConfig(LoraConfigStruct *);
uint8_t LoraInit(LoraConfigStruct *);
uint8_t LoraDefaultInit(void);

void LoraSetSPIHandler(SPI_HandleTypeDef *);
uint8_t LoraSendSPI(uint8_t, uint8_t, LoraConfigStruct *);
void LoraWriteRegister(uint8_t, uint8_t);
uint8_t LoraReadRegister(uint8_t);

// Functions with LoRa registers //
uint8_t GetLoraVersion(void);
uint8_t LoraGetRXBytes(void);
void LoraSetOCP(uint8_t);
void LoraSetFrequency(uint64_t);
void LoraSetTxPower(uint8_t, uint8_t);
void LoraSetIdle(void);
void LoraSleep(void);
uint8_t LoraGetSpreadingFactor(void);

uint8_t IsTransmitting(void);

// RX/TX
uint8_t LoraBeginPacket(uint8_t);
uint8_t LoraEndPacket(uint8_t);
void LoraWrite(const uint8_t* , size_t);
void LoraTransmit(const char*);
void LoraSendRF(const char*);

// Master Control
void LoraEnd(void);

/////////////////////////////////
#ifdef __cplusplus
}
#endif

#endif /* INC_LORA_H_ */
