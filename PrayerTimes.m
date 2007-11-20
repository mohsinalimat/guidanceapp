//
//  PrayerTimes.m
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "PrayerTimes.h"
#import <math.h>


@implementation PrayerTimes

- (id) init {
	self = [super init];
	if (self != nil)
	{
		Latitude = 0.0;
		Longitude = 0.0;
		Altitude = 0.0;
		Shafi = 1;
		TwilightDawnAngle = 18;
		TwilightSunsetAngle = 18;
	}
	return self;
}

 
- (void)setLatitude:(double)n
{
	Latitude = n;
}


- (void)setLongitude:(double)n
{
	Longitude = n;
}


- (void)setAltitude:(double)n
{
	Altitude = n;
}

- (void)setAsrMethod:(int)n
{
	if (n >= 0 && n < 2)
	{
		Shafi = n+1;
	}
	else
	{
		Shafi = 1;
	}
}

- (void)setIshaMethod:(int)n
{
	switch (n)
	{
		case 1:
			TwilightDawnAngle = 15;
			TwilightSunsetAngle = 15;
			break;
		case 0:
		default:
			TwilightDawnAngle = 18;
			TwilightSunsetAngle = 18;
			break;
	}
}

+ (double)rad2deg:(double)n
{
	return n * (180.0 / M_PI);
}


+ (double)deg2rad:(double)n
{
	return n * (M_PI / 180.0);
}


+ (int)sign:(double)n
{
	return fabs(n)/n;
}


+ (double)acot:(double)n
{
    return atan(1.0 / n);
}


+ (NSCalendarDate *) hoursToTime:(double)n
{
	NSCalendarDate *midnight = [[NSCalendarDate calendarDate]
								dateByAddingYears:0
								months:0
								days:0
								hours:-[[NSCalendarDate calendarDate] hourOfDay]
								minutes:-[[NSCalendarDate calendarDate] minuteOfHour]
								seconds:-[[NSCalendarDate calendarDate] secondOfMinute]];
	
	int hours = floor(n);
	int minutes = floor((n - hours) * 60);
	
	return [midnight dateByAddingYears:0 months:0 days:0 hours:hours minutes:minutes seconds:0];
}


- (void)calcTimes:(NSCalendarDate *)calcDate
{	
		
	timezone =((float)[[NSTimeZone systemTimeZone] secondsFromGMT])/3600;

	double rad_lat = [PrayerTimes deg2rad:Latitude];
	
	int day = [calcDate dayOfYear];
	
	if (Altitude == 0) Altitude = 1;
	double beta = (2 * M_PI * day) / 365.0;
	double d = (180.0 / M_PI) * (0.006918 - (0.399912 * cos(beta))
				+ (0.07057 * sin(beta))
				- (0.006758 * cos(2*beta))
				+ (0.000907 * sin(2*beta))
				- (0.002697 * cos(3*beta))
				+ (0.001480 * sin(3*beta)));
				
	double rad_d = [PrayerTimes deg2rad:d]; 			
				
	double t = 229.18 * (0.000075 + (0.001868 * cos(beta))
				- (0.032077 * sin(beta))
				- (0.014615 * cos(2*beta))
				- (0.040849 * sin(2*beta)));
	
	double r = 15.0 * timezone;
	double z = 12.0 + ((r - Longitude) / 15.0) - (t / 60.0);
	
	double xu = sin([PrayerTimes deg2rad:(-0.8333 - 0.0347
				* [PrayerTimes sign:Altitude]
				* sqrt(fabs(Altitude)))]
				- sin([PrayerTimes deg2rad:d])
				* sin([PrayerTimes deg2rad:Latitude]))
				/ (cos([PrayerTimes deg2rad:d])
				* cos([PrayerTimes deg2rad:Latitude]));
	
	double u;
	
	if (xu >= -1 && xu <= 1)
	{
		u = [PrayerTimes rad2deg:(1/15.0 * acos(xu))];
	}
	else
	{
		if (xu < -1)
		{
			// no sunset
		}
		else
		{
			// no sunrise
		}
	}
	
	double xvd = (-sin([PrayerTimes deg2rad:TwilightDawnAngle]) - sin([PrayerTimes deg2rad:d]) * sin([PrayerTimes deg2rad:Latitude]))
				/ (cos([PrayerTimes deg2rad:d]) * cos([PrayerTimes deg2rad:Latitude]));
	
	double vd = [PrayerTimes rad2deg:1/15.0 * acos(xvd)];
	
	double xvn = (-sin([PrayerTimes deg2rad:TwilightSunsetAngle]) - sin([PrayerTimes deg2rad:d]) * sin([PrayerTimes deg2rad:Latitude]))
				/ (cos([PrayerTimes deg2rad:d]) * cos([PrayerTimes deg2rad:Latitude]));
	
	double vn = [PrayerTimes rad2deg:1/15.0 * acos(xvn)];
	
	
	double w = [PrayerTimes rad2deg:(
		1/15.0 * acos(
			(
				sin(
					[PrayerTimes acot:(
						Shafi + tan(
							fabs(rad_lat - rad_d)
						)
					)]
				) - sin(rad_d) * sin(rad_lat)
			) /	
			( cos(rad_d) * cos(rad_lat) ) 
		)
	)];
	
	FajrTime = [PrayerTimes hoursToTime: z - vd];
	ShuruqTime = [PrayerTimes hoursToTime: z - u];
	DhuhurTime = [PrayerTimes hoursToTime: z];
	AsrTime = [PrayerTimes hoursToTime: z + w];
	MaghribTime = [PrayerTimes hoursToTime: z + u];
	IshaTime = [PrayerTimes hoursToTime: z + vn];
}

 
- (NSCalendarDate *)getFajrTime 
{
	return FajrTime;
}


- (NSCalendarDate *)getShuruqTime 
{
	return ShuruqTime;
}


- (NSCalendarDate *)getDhuhurTime 
{
	return DhuhurTime;
}


- (NSCalendarDate *)getAsrTime 
{
	return AsrTime;
}


- (NSCalendarDate *)getMaghribTime 
{
	return MaghribTime;
}


- (NSCalendarDate *)getIshaTime 
{
	return IshaTime;
}


@end
