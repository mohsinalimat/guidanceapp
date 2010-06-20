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
		Madhab = 1;
		Method = 2;
		SunsetAngle = 15;
		SunsetAngle = 15;
		CustomSunsetAngle = 15;
		CustomSunsetAngle = 15;
	}
	return self;
}

 

+ (int)dayOfYear:(NSDate *)date
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	int dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
	[gregorian release];
	return dayOfYear;
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


- (void)setMethod:(int)n {
	Method = n;
}


- (void)setCustomSunriseAngle:(float)n {
	CustomSunriseAngle = n;
}


- (void)setCustomSunsetAngle:(float)n {
	CustomSunsetAngle = n;	
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

- (void)setFajrOffset:(int)n
{
	FajrOffset = n - 15;
}

- (void)setShuruqOffset:(int)n
{
	ShuruqOffset = n - 15;
}

- (void)setDhuhurOffset:(int)n
{
	DhuhurOffset = n - 15;
}

- (void)setAsrOffset:(int)n
{
	AsrOffset = n - 15;
}

- (void)setMaghribOffset:(int)n
{
	MaghribOffset = n - 15;
}

- (void)setIshaOffset:(int)n
{
	IshaOffset = n - 15;
}

- (void)setMadhab:(int)n
{
	if (n >= 0 && n < 2)
	{
		Madhab = n+1;
	}
	else
	{
		Madhab = 1;
	}
}


- (void)setSystemTimezone:(BOOL)systemTZ 
{
	systemTimezone = systemTZ;
}

- (void)setTimezone:(float)tz 
{
	timezone = tz;
}


- (void)setDaylightSavings:(BOOL)dst {
	daylightSavings = dst;
}


+ (NSDate *)hoursToTime:(double)n : (NSDate *)calcDate
{
	int hour = floor(n);
	int minute = floor((n - hour) * 60);
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:calcDate];
	
	[comps setHour:hour];
	[comps setMinute:minute];
	
	NSDate *date = [gregorian dateFromComponents:comps];
	[gregorian release];
	
	return date;
}


- (void)calcTimes:(NSDate *)calcDate
{	
	// default to fajr time being valid
	BOOL validFajrTime = YES;
	
	// default isha time being valid
	BOOL validIshaTime = YES;
	
	
	float timezoneValue = 0;
	
	if(systemTimezone) {
		[NSTimeZone resetSystemTimeZone];
		timezoneValue = ((float)[[NSTimeZone systemTimeZone] secondsFromGMT])/3600;
	} else {
		timezoneValue = timezone;
		if(daylightSavings) timezoneValue++;
	}
	
	double rad_lat = [PrayerTimes deg2rad:Latitude];
	
	int day = [PrayerTimes dayOfYear:calcDate];
	
	if (Altitude == 0) Altitude = 1;
	
	switch (Method) {
		case 7:
			//custom method
			SunriseAngle = CustomSunriseAngle;
			SunsetAngle = CustomSunsetAngle;
			break;
		case 5:
			//Fixed Ishaa Angle Interval
			SunriseAngle = 19.5;
			SunsetAngle = 19.5;
			break;
		case 4:
			//Om Al-Qurra University
			SunriseAngle = 19;
			SunsetAngle = 19;
			break;
		case 3:
			//Muslim World League
			SunriseAngle = 18;
			SunsetAngle = 17;
			break;
		case 2:
			//Islamic Society of North America
			SunriseAngle = 15;
			SunsetAngle = 15;
			break;
		case 1:
			//University of Islamic Sciences, Karachi
			SunriseAngle = 18;
			SunsetAngle = 18;
			break;
		case 0:
			//Egyptian General Authority of Survey
			SunriseAngle = 20;
			SunsetAngle = 18;
			break;
		default:
			SunriseAngle = CustomSunriseAngle;
			SunsetAngle = CustomSunsetAngle;
			break;
	}

	
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
	
	double r = 15.0 * timezoneValue;
	
	// dhuhr calculation
	double z = 12.0 + ((r - Longitude) / 15.0) - (t / 60.0);
	
	
	// maghrib calculation
	double u;
	
	double xu = sin([PrayerTimes deg2rad:(-0.8333 - 0.0347
										  * [PrayerTimes sign:Altitude]
										  * sqrt(fabs(Altitude)))]
					- sin([PrayerTimes deg2rad:d])
					* sin([PrayerTimes deg2rad:Latitude]))
	/ (cos([PrayerTimes deg2rad:d])
	   * cos([PrayerTimes deg2rad:Latitude]));
	
	if (xu >= -1 && xu <= 1) {
		u = [PrayerTimes rad2deg:(1/15.0 * acos(xu))];
	} else {
		//invalid location
		return;
	}
	
	
	// fajr calculation
	double xvd = (-sin([PrayerTimes deg2rad:SunriseAngle]) - sin([PrayerTimes deg2rad:d]) * sin([PrayerTimes deg2rad:Latitude]))
	/ (cos([PrayerTimes deg2rad:d]) * cos([PrayerTimes deg2rad:Latitude]));

	if(xvd <= -1 || xvd >= 1) {
		validFajrTime = NO;
		xvd = (xvd/fabs(xvd)) * 0.999999;
	} 
	
	double vd = [PrayerTimes rad2deg:1/15.0 * acos(xvd)];
	
	
	
	// isha calculation
	double xvn = (-sin([PrayerTimes deg2rad:SunsetAngle]) - sin([PrayerTimes deg2rad:d]) * sin([PrayerTimes deg2rad:Latitude]))
	/ (cos([PrayerTimes deg2rad:d]) * cos([PrayerTimes deg2rad:Latitude]));
	
	if(xvn <= -1 || xvn >= 1) {
		validIshaTime = NO;
		xvn = (xvn/fabs(xvn)) * 0.999999;
	}
	
	double vn = [PrayerTimes rad2deg:1/15.0 * acos(xvn)];
	
	
	
	// asr calculation
	double w = [PrayerTimes rad2deg:(
									 1/15.0 * acos(
												   (
													sin(
														[PrayerTimes acot:(
																		   Madhab + tan(
																						fabs(rad_lat - rad_d)
																						)
																		   )]
														) - sin(rad_d) * sin(rad_lat)
													) /	
												   ( cos(rad_d) * cos(rad_lat) ) 
												   )
									 )];
	
	FajrTime = [PrayerTimes hoursToTime: z - vd : calcDate];
	ShuruqTime = [PrayerTimes hoursToTime: z - u : calcDate];
	DhuhurTime = [PrayerTimes hoursToTime: z : calcDate];
	AsrTime = [PrayerTimes hoursToTime: z + w : calcDate];
	MaghribTime = [PrayerTimes hoursToTime: z + u : calcDate];
	
	if(Method == 4 || Method == 5) {
		IshaTime = [PrayerTimes hoursToTime: z + u + 1.5 : calcDate];
	} else {
		IshaTime = [PrayerTimes hoursToTime: z + vn : calcDate];
	}
	
	
	// apply corrections to high latitude locations
	if(Latitude > 48) {
		
		// time from maghrib until tomorrow's shuruq
		double nightTime = ((24 - (z + u)) + (z - u));
		
		// calculate and aplly fajr adjustment
		double fajrDiff = (1/60.0 * SunriseAngle) * nightTime;
		if(!validFajrTime || ((z - u) - (z - vd)) > fajrDiff) {
			FajrTime = [PrayerTimes hoursToTime: z - u - fajrDiff : calcDate];
		}
		
		// calculate and apply isha adjustment if we are not using a fixed isha time method
		if(Method != 4 && Method != 5) {
			double ishaDiff = (1/60.0 * SunsetAngle) * nightTime;
			if(!validIshaTime || ((z + vn) - (z + u)) > ishaDiff) {
				IshaTime = [PrayerTimes hoursToTime: z + u + ishaDiff : calcDate];
			}			
		}	
	}
}


- (NSDate *)getFajrTime 
{
	//offset in minutes * 60 = seconds
	return [FajrTime addTimeInterval:FajrOffset*60];	
}


- (NSDate *)getShuruqTime 
{
	//offset in minutes * 60 = seconds...
	return [ShuruqTime addTimeInterval:ShuruqOffset*60];	
}


- (NSDate *)getDhuhurTime 
{
	//offset in minutes * 60 = seconds...
	return [DhuhurTime addTimeInterval:DhuhurOffset*60];	
}


- (NSDate *)getAsrTime 
{
	//offset in minutes * 60 = seconds...
	return [AsrTime addTimeInterval:AsrOffset*60];	
}


- (NSDate *)getMaghribTime 
{
	//offset in minutes * 60 = seconds...
	return [MaghribTime addTimeInterval:MaghribOffset*60];	
}


- (NSDate *)getIshaTime 
{
	//offset in minutes * 60 = seconds...
	return [IshaTime addTimeInterval:IshaOffset*60];	
}

- (void)setDate:(NSDate *)date
{
	DateTime = date;
	[self calcTimes:date];
}

- (NSDate *)getDate
{
	return DateTime;
}


@end
