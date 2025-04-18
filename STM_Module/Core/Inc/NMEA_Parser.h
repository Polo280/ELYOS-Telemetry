#ifndef NMEA_PARSER_H
#define NMEA_PARSER_H

#include <stdio.h>
#include <stdint.h>
#include <string.h>

// SPLITTER
#define MAX_SENTENCES_SPLIT 4
#define MAX_SENTENCE_LENGTH 100

/////// NMEA SENTENCE TYPES ///////
// Global Positioning System Fix Data
typedef struct {
	uint32_t fix_time;
	uint8_t  fix_quality;
	uint8_t  sat_count;
	float 	 horizontal_dilution;
	float    altitude;
	float    latitude;
	float    longitude;
	char 	 lon_direction;
	char     lat_direction;
} GPS_GPGGA_DATA;

// Recomented Minimum Specific GPS / Transit Data
typedef struct {
	uint32_t fix_time;
	uint32_t date;
	float 	 speed_knots;
	float 	 track_angle;
	float 	 mag_variation;
	float 	 latitude;
	float	 longitude;
	char 	 status;
	char 	 lat_direction;
	char 	 lon_direction;
	char 	 mag_variation_dir;
} GPS_GPRMC_DATA;

// Geographic Position (Latitude/Longitude)
typedef struct {
	uint32_t fix_time;
	double 	 latitude;
	double 	 longitude;
	char 	 status;
	char 	 lat_direction;
	char 	 lon_direction;
} GPS_GPGLL_DATA;

// Track made good and ground speed
typedef struct {
	float true_track;
	float mag_track;
	float speed_knots;
	float speed_kmh;
} GPS_GPVTG_DATA;

// GNSS DOP and active satellites
typedef struct {
	float pdop;
	float hdop;
	float vdop;
	char  operation_mode;
} GPS_GPGSA_DATA;

// GNSS Satellites in view
typedef struct {
	uint8_t sentence_num;
	uint8_t total_sats;
} GPS_GPGSV_DATA;

// Time and data
typedef struct {
	uint32_t utc_time;
	uint16_t year;
	uint8_t  day;
	uint8_t  month;
} GPS_GPZDA_DATA;


// Relevant data for this telemetry system
typedef struct {
	GPS_GPGGA_DATA GPGGA_data;
	GPS_GPVTG_DATA GPVTG_data;
	GPS_GPRMC_DATA GPRMC_data;
} GPS_DATA;

// Parsing functions
void processGPGGA(const char*, GPS_GPGGA_DATA*);
void processGPRMC(const char*, GPS_GPRMC_DATA*);
void processGPGLL(const char*, GPS_GPGLL_DATA*);
void processGPVTG(const char*, GPS_GPVTG_DATA*);
void processGPGSA(const char*, GPS_GPGSA_DATA*);
void processGPGSV(const char*, GPS_GPGSV_DATA*);
void processGPZDA(const char*, GPS_GPZDA_DATA*);
void parseGPSData(const char*, GPS_DATA*);
void splitNMEASentences(const char *, char[MAX_SENTENCES_SPLIT][MAX_SENTENCE_LENGTH]);

#endif /* NMEA_PARSER_H */
