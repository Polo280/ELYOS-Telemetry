#ifndef INC_CONVERSIONS_H_
#define INC_CONVERSIONS_H_

#include <math.h>

#define EARTH_RADIUS   (float) 6371000.0  // Meters
#define KNOTS_TO_MPS   (float) 0.514444   // Meters per second

float deg_to_rad(float);
void latlon_to_xy(float, float, float, float, float*, float*);
void get_GPS_VelocityComponents(float, float, float*, float*);

#endif /* INC_CONVERSIONS_H_ */
