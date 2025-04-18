#ifndef __ADC_H__
#define __ADC_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

extern void Error_Handler();
extern ADC_HandleTypeDef hadc1;

void MX_ADC1_Init(void);
extern uint16_t pollFromChannelADC(uint32_t channel);

#ifdef __cplusplus
}
#endif

#endif /* __ADC_H__ */

