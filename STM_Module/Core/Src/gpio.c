#include "gpio.h"

void MX_GPIO_Init(void)
{
 GPIO_InitTypeDef GPIO_InitStruct = {0};

 /* GPIO Ports Clock Enable */
 __HAL_RCC_GPIOA_CLK_ENABLE();
 __HAL_RCC_GPIOB_CLK_ENABLE();

 /*Configure GPIO pin Output Level */
 HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_RESET);

 /*Configure GPIO pin Output Level */
 HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, GPIO_PIN_RESET);

 // RPM Hall sensor
 /*Configure GPIO pin : PA1 */
 GPIO_InitStruct.Pin = GPIO_PIN_1;
 GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
 GPIO_InitStruct.Pull = GPIO_PULLDOWN;
 HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

 // Chip select Lora
 /*Configure GPIO pin : PA4 */
// GPIO_InitStruct.Pin = GPIO_PIN_4;
// GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
// GPIO_InitStruct.Pull = GPIO_NOPULL;
// GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
// HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

 // Routed to IT pin BNO055
 /*Configure GPIO pin : PB0 */
 GPIO_InitStruct.Pin = GPIO_PIN_0;
 GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
 GPIO_InitStruct.Pull = GPIO_PULLUP;
 HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

 // Blinker
 /*Configure GPIO pin : PB1 */
 GPIO_InitStruct.Pin = GPIO_PIN_1;
 GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
 GPIO_InitStruct.Pull = GPIO_NOPULL;
 GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
 HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

}
