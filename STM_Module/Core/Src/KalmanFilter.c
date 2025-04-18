#include "KalmanFilter.h"

// Parameters for this application
static const float delta_t = KALMAN_DELTA_T_SECS;
// Functions
static void matricesToZero(KalmanFusion* kf);
static void matrixToZero(float32_t*, uint8_t);
static void initMatrices(KalmanFusion* kf);


void KF_Init(KalmanFusion* kf) {
	// Start allocated matrices in a known value (0)
	matricesToZero(kf);
	// Initialize matrices
	initMatrices(kf);
}


void KF_Predict(KalmanFusion* kf, float32_t* in_data){
	float32_t temp1_data[SQUARE_MATRIX_SIZE];
	float32_t temp2_data[SQUARE_MATRIX_SIZE];
	float32_t control_aux_data[STATE_SPACE_VECTOR_ROWS];
	float32_t input_data[CONTROL_INPUTS];

	// Start to known values
	matrixToZero(temp1_data, SQUARE_MATRIX_SIZE);
	matrixToZero(temp2_data, SQUARE_MATRIX_SIZE);
	matrixToZero(control_aux_data, STATE_SPACE_VECTOR_ROWS);
	// Set control inputs
	input_data[0] = *in_data;
	input_data[1] = *(in_data + 1);
	input_data[2] = *(in_data + 2);

	// Matrices
	arm_matrix_instance_f32 control_aux;
	arm_matrix_instance_f32 temp1;
	arm_matrix_instance_f32 temp2;
	arm_matrix_instance_f32 input;
	// Initialize
	arm_mat_init_f32(&control_aux, STATE_SPACE_VECTOR_ROWS, 1, control_aux_data);
	arm_mat_init_f32(&temp1, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, temp1_data);
	arm_mat_init_f32(&temp2, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, temp2_data);
	arm_mat_init_f32(&input, CONTROL_INPUTS, 1, input_data);
	// Prediction stage 1
	// x_check_k = F * x_hat_prev + B * v_prev
	arm_mat_mult_f32(&kf->F, &kf->x_hat_prev, &kf->x_check);     // F * x_hat_prev
	arm_mat_mult_f32(&kf->B, &input, &control_aux);		 		 // B * u
	arm_mat_add_f32(&kf->x_check, &control_aux, &kf->x_check);   // F * x_hat_prev + B * u

	// Prediction stage 2
	// P_check_k = F * P_hat_prev * F^T + Q
	arm_mat_mult_f32(&kf->F, &kf->P_hat_prev, &temp1);
	arm_mat_trans_f32(&kf->F, &temp2);
	arm_mat_mult_f32(&temp1, &temp2, &kf->P_check);
	arm_mat_add_f32(&kf->P_check, &kf->Q, &kf->P_check);
}


void KF_Update(KalmanFusion* kf, arm_matrix_instance_f32* Z_k){
	float32_t numerator_data[SQUARE_MATRIX_SIZE];
	float32_t K_gain_data[SQUARE_MATRIX_SIZE];
	float32_t temp_H_P_data[SQUARE_MATRIX_SIZE];
	float32_t temp_H_X_data[STATE_SPACE_VECTOR_ROWS];
	float32_t HPH_data[SQUARE_MATRIX_SIZE];
	float32_t inverse_aux_data[SQUARE_MATRIX_SIZE];
	//float32_t subtract_aux[SQUARE_MATRIX_SIZE];
	float32_t KH_data[SQUARE_MATRIX_SIZE];
	float32_t I_minus_KH_data[SQUARE_MATRIX_SIZE];

	// Start to known values
	matrixToZero(numerator_data, SQUARE_MATRIX_SIZE);
	matrixToZero(K_gain_data, SQUARE_MATRIX_SIZE);
	matrixToZero(temp_H_P_data, SQUARE_MATRIX_SIZE);
	matrixToZero(temp_H_X_data, STATE_SPACE_VECTOR_ROWS);
	matrixToZero(HPH_data, SQUARE_MATRIX_SIZE);
	matrixToZero(inverse_aux_data, SQUARE_MATRIX_SIZE);
	matrixToZero(KH_data, SQUARE_MATRIX_SIZE);
	matrixToZero(I_minus_KH_data, SQUARE_MATRIX_SIZE);
	// Matrices
	arm_matrix_instance_f32 numerator;
	arm_matrix_instance_f32 K_gain;
	arm_matrix_instance_f32 temp_H_P;
	arm_matrix_instance_f32 temp_H_X;
	arm_matrix_instance_f32 HPH;
	arm_matrix_instance_f32 inverse_aux;
	arm_matrix_instance_f32 KH;
	arm_matrix_instance_f32 I_minus_KH;
	// Initialize
	arm_mat_init_f32(&numerator, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, numerator_data);
	arm_mat_init_f32(&K_gain, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, K_gain_data);
	arm_mat_init_f32(&temp_H_P, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, temp_H_P_data);
	arm_mat_init_f32(&temp_H_X, STATE_SPACE_VECTOR_ROWS, 1, temp_H_X_data);
	arm_mat_init_f32(&HPH, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, HPH_data);
	arm_mat_init_f32(&inverse_aux, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, inverse_aux_data);
	arm_mat_init_f32(&KH, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, KH_data);
	arm_mat_init_f32(&I_minus_KH, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, I_minus_KH_data);

	// K_k = P_check_k * H^T * (H * P_check_k * H^T + 0.01)^(-1)
	arm_mat_mult_f32(&kf->P_check, &kf->H_transposed, &numerator);  // P_check_k * H^T
	arm_mat_mult_f32(&kf->H, &kf->P_check, &temp_H_P);				// H * P_check_k
	arm_mat_mult_f32(&temp_H_P, &kf->H_transposed, &HPH); 			// H * P_check_k * H^T
	arm_mat_add_f32(&HPH, &kf->R, &inverse_aux);   				    // (H * P_check_k * H^T + 0.01)^(-1)
	arm_status flag = arm_mat_inverse_f32(&inverse_aux, &K_gain);
	if(flag != ARM_MATH_SUCCESS){
		printf("Non invertible matrix\n");
	}
	arm_mat_mult_f32(&K_gain, &numerator, &K_gain);	 // Total K gain

	// x_hat_k = x_check_k + K_k * (Z_k - H * x_check_k)
	arm_mat_mult_f32(&kf->H, &kf->x_check, &temp_H_X);			// H * x_check_k
	arm_mat_sub_f32(Z_k, &temp_H_X, &temp_H_X);					// Z_k - H * x_check_k
	arm_mat_mult_f32(&K_gain, &temp_H_X, &temp_H_X);			// K_k * (Z_k - H * x_check_k)
	arm_mat_add_f32(&kf->x_check, &temp_H_X, &kf->x_hat_prev);  // Corrected estimate

	// P_hat_k = (I - K_k * H) * P_check_k
	arm_mat_mult_f32(&K_gain, &kf->H, &KH);         // K * H
	arm_mat_sub_f32(&kf->I, &KH, &I_minus_KH);      // I - K * H
	arm_mat_mult_f32(&I_minus_KH, &kf->P_check, &kf->P_hat_prev); // Update P_hat_k
}


static void initMatrices(KalmanFusion* kf){
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		// State propagation A (or F)
		kf->F_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 1;
		kf->F_transposed_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 1;

		if(i % 2 == 0){
			// State propagation A (or F)
			kf->F_data[i * (STATE_SPACE_VECTOR_ROWS + 1) + 1] = delta_t;
		}else{
			kf->F_transposed_data[i * (STATE_SPACE_VECTOR_ROWS + 1) - 1] = delta_t;
		}
	}
	arm_mat_init_f32(&kf->F, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->F_data);

	// Control input
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		if(i < 3){
			kf->B_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = (delta_t * delta_t) / 2;  // ddt
		}
		if(i % 2 == 1){
			kf->B_data[i * (CONTROL_INPUTS) + (uint8_t)(i / 2)] = delta_t;  // dt
		}
	}
	arm_mat_init_f32(&kf->B, STATE_SPACE_VECTOR_ROWS, CONTROL_INPUTS, kf->B_data);

	// Measurements (GPS)
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		// Assuming position and velocity measurements in X and Y only
		if(i < 4){
			kf->H_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 1;
			kf->H_transposed_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 1;  // In this case they remain the same
		}
	}
	arm_mat_init_f32(&kf->H, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->H_data);
	arm_mat_init_f32(&kf->H_transposed, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->H_transposed_data);

	// Identity matrix
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		kf->I_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 1;
	}
	arm_mat_init_f32(&kf->I, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->I_data);

	// Process (Model) Covariance
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		kf->Q_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 0.1;
	}
	arm_mat_init_f32(&kf->Q, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->Q_data);

	// Sensor covariance matrix
	for(uint8_t i=0; i < STATE_SPACE_VECTOR_ROWS; i++){
		kf->R_data[i * (STATE_SPACE_VECTOR_ROWS + 1)] = 0.1;   // ADJUST THIS AND FINE TUNE
	}
	arm_mat_init_f32(&kf->R, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->R_data);   // CHECK DIMENSIONALITY

	// KF matrices
	arm_mat_init_f32(&kf->P_hat_prev, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->P_hat_prev_data);
	arm_mat_init_f32(&kf->P_check, STATE_SPACE_VECTOR_ROWS, STATE_SPACE_VECTOR_ROWS, kf->P_check_data);
	arm_mat_init_f32(&kf->x_hat_prev, STATE_SPACE_VECTOR_ROWS, 1, kf->x_hat_prev_data);
	arm_mat_init_f32(&kf->x_check, STATE_SPACE_VECTOR_ROWS, 1, kf->x_check_data);
}


static void matrixToZero(float32_t* data_array, uint8_t array_size){
	memset(data_array, 0, sizeof(float32_t) * array_size);
}


static void matricesToZero(KalmanFusion* kf){
	// State propagation (A)
	matrixToZero(kf->F_data, SQUARE_MATRIX_SIZE);
	matrixToZero(kf->F_transposed_data, SQUARE_MATRIX_SIZE);
	// Control input (B)
	matrixToZero(kf->B_data, STATE_SPACE_VECTOR_ROWS * CONTROL_INPUTS);
	// Previous estimate
	matrixToZero(kf->x_hat_prev_data, STATE_SPACE_VECTOR_ROWS);
	// Process Noise (Model) Covariance Q
	matrixToZero(kf->Q_data, SQUARE_MATRIX_SIZE);
	// Measurement Matrix (H)
	matrixToZero(kf->H_data, SQUARE_MATRIX_SIZE);
	matrixToZero(kf->H_transposed_data, SQUARE_MATRIX_SIZE);
	// Previous Total Error
	matrixToZero(kf->P_hat_prev_data, SQUARE_MATRIX_SIZE);
	// Sensor covariance
	matrixToZero(kf->R_data, SQUARE_MATRIX_SIZE);
	// Identity matrix auxiliary
	matrixToZero(kf->I_data, SQUARE_MATRIX_SIZE);
	// Update
	matrixToZero(kf->x_check_data, STATE_SPACE_VECTOR_ROWS);
	matrixToZero(kf->P_check_data, SQUARE_MATRIX_SIZE);
}


void print_matrix_f32(const arm_matrix_instance_f32 *mat, const char *name) {
    printf("Matrix %s (%d x %d):\n", name, mat->numRows, mat->numCols);

    for (int i = 0; i < mat->numRows; i++) {
        for (int j = 0; j < mat->numCols; j++) {
            printf("%8.4f ", mat->pData[i * mat->numCols + j]); // Print with 4 decimal places
        }
        printf("\n");
    }
    printf("\n"); // Extra newline for readability
}


//void print_estimated_state(KalmanFusion* kf, UART_HandleTypeDef* huart_instance){
//	char aux_buff[100];
//	snprintf(aux_buff, sizeof(aux_buff),
//	         "X:%d.%03d, dX:%d.%03d\nY:%d.%03d, dY:%d.%03d\nZ:%d.%03d, dZ:%d.%03d\n",
//	         (int)kf->x_hat_prev_data[0], abs((int)(kf->x_hat_prev_data[0]*1000)%1000),
//	         (int)kf->x_hat_prev_data[1], abs((int)(kf->x_hat_prev_data[1]*1000)%1000),
//	         (int)kf->x_hat_prev_data[2], abs((int)(kf->x_hat_prev_data[2]*1000)%1000),
//	         (int)kf->x_hat_prev_data[3], abs((int)(kf->x_hat_prev_data[3]*1000)%1000),
//	         (int)kf->x_hat_prev_data[4], abs((int)(kf->x_hat_prev_data[4]*1000)%1000),
//	         (int)kf->x_hat_prev_data[5], abs((int)(kf->x_hat_prev_data[5]*1000)%1000));
//
//	HAL_UART_Transmit(huart_instance, (uint8_t*)aux_buff, sizeof(aux_buff), 20);
//}
