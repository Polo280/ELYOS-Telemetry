#ifndef __USART_H__
#define __USART_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"

extern UART_HandleTypeDef huart1;
extern UART_HandleTypeDef huart2;

extern void Error_Handler();
void MX_USART1_UART_Init(void);
void MX_USART2_UART_Init(void);


#ifdef __cplusplus
}
#endif

#endif /* __USART_H__ */

