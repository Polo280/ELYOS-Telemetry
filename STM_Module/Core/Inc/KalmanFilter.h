#ifndef INC_KALMANFILTER_H_
#define INC_KALMANFILTER_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stm32l4xx_hal.h"
#include "arm_math.h"
#include <math.h>

#define KALMAN_DELTA_T_SECS 0.01
#define STATE_SPACE_VECTOR_ROWS 6
#define SQUARE_MATRIX_SIZE STATE_SPACE_VECTOR_ROWS * STATE_SPACE_VECTOR_ROWS
#define CONTROL_INPUTS 3

typedef struct {
  arm_matrix_instance_f32 x_hat_prev;
  arm_matrix_instance_f32 P_hat_prev;
  arm_matrix_instance_f32 F;
  arm_matrix_instance_f32 B;
  arm_matrix_instance_f32 Q;
  arm_matrix_instance_f32 H;
  arm_matrix_instance_f32 H_transposed;
  arm_matrix_instance_f32 R;
  arm_matrix_instance_f32 I;
  // Update
  arm_matrix_instance_f32 P_check;
  arm_matrix_instance_f32 x_check;

  float32_t x_hat_prev_data[STATE_SPACE_VECTOR_ROWS];
  float32_t P_hat_prev_data[SQUARE_MATRIX_SIZE];
  float32_t F_data[SQUARE_MATRIX_SIZE];
  float32_t F_transposed_data[SQUARE_MATRIX_SIZE];
  float32_t B_data[STATE_SPACE_VECTOR_ROWS * CONTROL_INPUTS];
  float32_t Q_data[SQUARE_MATRIX_SIZE];
  float32_t H_data[SQUARE_MATRIX_SIZE];
  float32_t H_transposed_data[SQUARE_MATRIX_SIZE];
  float32_t R_data[SQUARE_MATRIX_SIZE];  // CHECK THIS
  float32_t I_data[SQUARE_MATRIX_SIZE];  // Identity
  // Update
  float32_t P_check_data[SQUARE_MATRIX_SIZE];
  float32_t x_check_data[STATE_SPACE_VECTOR_ROWS];

} KalmanFusion;


extern void KF_Init(KalmanFusion*);
extern void KF_Predict(KalmanFusion*, float32_t*);
extern void KF_Update(KalmanFusion*, arm_matrix_instance_f32*);
extern void print_matrix_f32(const arm_matrix_instance_f32*, const char*);
extern void print_estimated_state(KalmanFusion*, UART_HandleTypeDef*);
// Manage different sensor updates
extern void KF_GPS_Update(KalmanFusion*);
extern void KF_RPM_Update(KalmanFusion*);

#endif /* INC_KALMANFILTER_H_ */
