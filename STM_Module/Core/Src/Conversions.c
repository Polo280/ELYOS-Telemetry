#include "Conversions.h"

inline float deg_to_rad(float deg) {
    return deg * (M_PI / 180.0f);
}

// Convert GPS degrees to relative X,Y for Kalman Filter
// NOTE: lat0 and lon0 are the reference coordinates for your point (0,0) in the space
void latlon_to_xy(float lat0, float lon0, float lat, float lon, float *x, float *y) {
    float dlat = deg_to_rad(lat - lat0);
    float dlon = deg_to_rad(lon - lon0);

    float mean_lat = deg_to_rad((lat + lat0) / 2.0f);

    *x = EARTH_RADIUS * dlon * cosf(mean_lat);  // East-West
    *y = EARTH_RADIUS * dlat;                   // North-South
}


void get_GPS_VelocityComponents(float speed_knots, float heading_deg, float* vx, float* vy){
    float speed_mps = speed_knots * KNOTS_TO_MPS;
    float heading_rad = deg_to_rad(heading_deg);

    // Note: heading 0° is North, 90° is East (standard in GPS)
    //   X = East = sin(heading)
    //   Y = North = cos(heading)

    *vx = speed_mps * sinf(heading_rad);  // East
    *vy = speed_mps * cosf(heading_rad);  // North
}


