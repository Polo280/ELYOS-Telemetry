#include "NMEA_Parser.h"
#include <stdlib.h>

///////////////////// PROCESS SENTENCES /////////////////////
void processGPGGA(const char* sentence, GPS_GPGGA_DATA* gga_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	// To store sequentially in aux buffer
	uint8_t index = 0;
	uint8_t item_count = 0;
	// Parsing auxiliaries
	uint32_t aux = 0;


	while(*c != '\r' && *c != '\n' && *c != '\0'){
		if(*c == ','){
			if(aux_buff[0] != '\0'){
				// Null terminate the buffer to cast
				aux_buff[index] = '\0';

				switch(item_count){
				case 1:
					// Fix time
					aux = (uint32_t)strtoul(aux_buff, NULL, 10);
					if(aux > 100){
						gga_data->fix_time = aux;
					}
					break;
				case 2:
					// Latitude
					gga_data->latitude = strtof(aux_buff, NULL);
					break;
				case 3:
					// Latitude direction
					gga_data->lat_direction = aux_buff[0];
					break;
				case 4:
					// Longitude
					gga_data->longitude = strtof(aux_buff, NULL);
					break;
				case 5:
					// Longitude direction
					gga_data->lon_direction = aux_buff[0];
					break;
				case 6:
					// Fix quality
					gga_data->fix_quality = (uint8_t)strtod(aux_buff, NULL);
					break;
				case 7:
					// Satellite count
					gga_data->sat_count = (uint8_t)strtod(aux_buff, NULL);
					break;
				case 8:
					// Horizontal dilution
					gga_data->horizontal_dilution = strtof(aux_buff, NULL);
					break;
				case 9:
					// Altitude
					gga_data->altitude = strtof(aux_buff, NULL);
					break;
				default:
					break;
				}
				index = 0;
				memset(aux_buff, 0, sizeof(aux_buff));
			}
			item_count ++;
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPRMC(const char* sentence, GPS_GPRMC_DATA* rmc_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	// To store sequentially in aux buffer
	uint8_t index = 0;
	uint8_t item_count = 0;
	// Parsing auxiliaries
	char validator = '\0';
	uint32_t aux = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			if(aux_buff[0] != '\0'){
				// Null terminate the buffer to cast
				aux_buff[index] = '\0';

				switch(item_count){
				case 1:
					// Fix time
					 aux = (uint32_t)strtoul(aux_buff, NULL, 10);
					// Filter out incomplete fix time
					if(aux > 100){
						rmc_data->fix_time = aux;
					}
					break;
				case 2:
					// Status code (A = Active, V = Void)
					validator = aux_buff[0];
					if(validator != 'V' && validator != 'A'){
						validator = 'X';   // NULL or invalid data
					}
					rmc_data->status = validator;
					break;
				case 3:
					// Latitude
					if(validator == 'A'){
						float NMEA_lat = strtof(aux_buff, NULL);
						// Format to decimal degrees
						int degrees = (int)(NMEA_lat / 100);
						float minutes = NMEA_lat - (degrees * 100);
						rmc_data->latitude = degrees + (minutes / 60.0);
					}
					break;
				case 4:
					// Latitude direction
					if(validator == 'A'){
						rmc_data->lat_direction = aux_buff[0];
						if(rmc_data->lat_direction == 'S'){
							rmc_data->latitude *= -1 ;
						}
					}
					break;
				case 5:
					// Longitude
					if(validator == 'A'){
						float NMEA_lon = strtof(aux_buff, NULL);
						int lon_degrees = (int)(NMEA_lon / 100);
						float lon_minutes = NMEA_lon - (lon_degrees * 100);
						rmc_data->longitude = lon_degrees + (lon_minutes / 60.0);
					}
					break;
				case 6:
					// Longitude direction
					if(validator == 'A'){
						rmc_data->lon_direction = aux_buff[0];
						if(rmc_data->lon_direction == 'W'){
							rmc_data->longitude *= -1 ;
						}
					}
					break;
				case 7:
					// Speed in knots
					rmc_data->speed_knots = strtof(aux_buff, NULL);
					break;
				case 8:
					// Track angle
					rmc_data->track_angle = strtof(aux_buff, NULL);
					break;
				case 9:
					// Date
					aux = (uint32_t)strtoul(aux_buff, NULL, 10);
					// Filter out incomplete date
					if(aux > 100){
						rmc_data->date = aux;
					}
					break;
				case 10:
					// Magnetic variation degrees
					if(validator == 'A'){
						rmc_data->mag_variation = strtof(aux_buff, NULL);
					}
					break;
				case 11:
					// Magnetic variation direction
					if(validator == 'A'){
						rmc_data->mag_variation_dir = aux_buff[0];
					}
					break;
				default:
					break;
				}
				index = 0;
				memset(aux_buff, 0, sizeof(aux_buff));
			}
			item_count ++;
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPGLL(const char* sentence, GPS_GPGLL_DATA* gll_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	uint8_t index = 0;  // To store sequentially in aux buffer
	uint8_t item_count = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			switch(item_count){
			case 1:
				// Latitude
				gll_data->latitude = strtod(aux_buff, NULL);
				break;
			case 2:
				// Latitude direction
				gll_data->lat_direction = aux_buff[0];
				break;
			case 3:
				// Latitude
				gll_data->longitude = strtod(aux_buff, NULL);
				break;
			case 4:
				// Longitude direction
				gll_data->lon_direction = aux_buff[0];
				break;
			case 5:
				// Status code (A = Active, V = Void)
				gll_data->status = aux_buff[0];
				break;
			default:
				break;
			}

			index = 0;
			item_count ++;
			memset(aux_buff, 0, sizeof(aux_buff));
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPVTG(const char* sentence, GPS_GPVTG_DATA* vtg_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	uint8_t index = 0;  // To store sequentially in aux buffer
	uint8_t item_count = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			switch(item_count){
			case 1:
				// True track made good
				vtg_data->true_track = strtof(aux_buff, NULL);
				break;
			case 2:
				// Magnetic track made good
				vtg_data->mag_track = strtof(aux_buff, NULL);
				break;
			case 3:
				// Speed in knots
				vtg_data->speed_knots = strtof(aux_buff, NULL);
				break;
			case 4:
				// Speed in km/h
				vtg_data->speed_kmh = strtof(aux_buff, NULL);
				break;
			default:
				break;
			}

			index = 0;
			item_count ++;
			memset(aux_buff, 0, sizeof(aux_buff));
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPGSA(const char* sentence, GPS_GPGSA_DATA* gsa_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	uint8_t index = 0;  // To store sequentially in aux buffer
	uint8_t item_count = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			switch(item_count){
			case 1:
				// Operation mode (A = Auto, M = Manual)
				gsa_data->operation_mode = aux_buff[0];
				break;
			default:
				break;
			}

			index = 0;
			item_count ++;
			memset(aux_buff, 0, sizeof(aux_buff));
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPGSV(const char* sentence, GPS_GPGSV_DATA* gsv_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	uint8_t index = 0;  // To store sequentially in aux buffer
	uint8_t item_count = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			switch(item_count){
			case 2:
				// Sentence number
				gsv_data->sentence_num = strtol(aux_buff, NULL, 10);
				break;
			case 3:
				// Number of satellites in view
				gsv_data->total_sats = strtol(aux_buff, NULL, 10);
				break;
			default:
				break;
			}

			index = 0;
			item_count ++;
			memset(aux_buff, 0, sizeof(aux_buff));
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

void processGPZDA(const char* sentence, GPS_GPZDA_DATA* zda_data){
	// Iterate through sentence bytes
	char aux_buff[25];
	const char* c = sentence;
	uint8_t index = 0;  // To store sequentially in aux buffer
	uint8_t item_count = 0;

	while(*c != '\n' && *c != '\0'){
		if(*c == ','){
			switch(item_count){
			case 1:
				// UTC time
				zda_data->utc_time = (uint32_t)strtoul(aux_buff, NULL, 10);
				break;
			case 2:
				// Day
				zda_data->day = strtol(aux_buff, NULL, 10);
				break;
			case 3:
				// Month
				zda_data->month = strtol(aux_buff, NULL, 10);
				break;
			case 4:
				// Year
				zda_data->year = (uint16_t)strtoul(aux_buff, NULL, 10);
				break;
			default:
				break;
			}

			index = 0;
			item_count ++;
			memset(aux_buff, 0, sizeof(aux_buff));
		}
		else{
			aux_buff[index] = *c;
			index ++;
		}
		c ++;
	}
}

/////////////////////////////////////////////////////////////

// Split valid NMEA Sentences in a message
void splitNMEASentences(const char *buffer, char sentences[MAX_SENTENCES_SPLIT][MAX_SENTENCE_LENGTH]){
	uint8_t sentence_count = 0;
	// Read only pointers
	const char* start = buffer;
	const char* end;

	while((end = strstr(start, "\n")) != NULL){
		size_t length = end - start + 1;

		if (length < MAX_SENTENCE_LENGTH && sentence_count < MAX_SENTENCES_SPLIT) {
			strncpy(sentences[sentence_count], start, length);
			sentences[sentence_count][length] = '\0';  // Null-terminate the string
			sentence_count++;
		}
		start = end + 1;
	}
}

// Parse and store all relevant data (Modify this to store relevant data for the application)
void parseGPSData(const char* gps_buffer, GPS_DATA* gps_data){
	// All NMEA sentences start with $GP(x_x_x), -> Use this to select parse mode
	char id[3] = {*(gps_buffer + 4), *(gps_buffer + 5)};
	// Compare id and parse accordingly
	if(strcmp(id, "GA") == 0){  // GGA
		processGPGGA(gps_buffer, &gps_data->GPGGA_data);
	}
	else if(strcmp(id, "MC") == 0){ // RMC
		processGPRMC(gps_buffer, &gps_data->GPRMC_data);
	}
//	else if(strcmp(id, "LL") == 0){ // GLL
//		processGPGLL(gps_buffer, &gps_data->GPGLL_data);
//	}
//	else if(strcmp(id, "TG") == 0){ // VTG
//		processGPVTG(gps_buffer, &gps_data->GPVTG_data);
//	}
//	else if(strcmp(id, "SA") == 0){ // GSA
//		processGPGSA(gps_buffer, &gps_data->GPGSA_data);
//	}
//	else if(strcmp(id, "SV") == 0){ // GSV
//		processGPGSV(gps_buffer, &gps_data->GPGSV_data);
//	}
//	else if(strcmp(id, "DA") == 0){ // ZDA
//		processGPZDA(gps_buffer, &gps_data->GPZDA_data);
//	}
}
