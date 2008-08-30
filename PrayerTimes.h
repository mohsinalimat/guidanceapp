//
//  PrayerTimes.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//
 
#import <Cocoa/Cocoa.h>


@interface PrayerTimes : NSObject {
	double Latitude;
	double Longitude;
	double Altitude;
	int Madhab;
	int Method;
	double CustomSunriseAngle;
	double CustomSunsetAngle;
	double SunriseAngle;
	double SunsetAngle;
	BOOL systemTimezone;
	float timezone;
	BOOL daylightSavings;
	
	int FajrOffset;
	int ShuruqOffset;
	int DhuhurOffset;
	int AsrOffset;
	int MaghribOffset;
	int IshaOffset;
	
	NSDate *FajrTime;
	NSDate *ShuruqTime;
	NSDate *DhuhurTime;
	NSDate *AsrTime;
	NSDate *MaghribTime;
	NSDate *IshaTime;
	
	NSDate *DateTime;
}

- (void)setFajrOffset:(int)n;
- (void)setShuruqOffset:(int)n;
- (void)setDhuhurOffset:(int)n;
- (void)setAsrOffset:(int)n;
- (void)setMaghribOffset:(int)n;
- (void)setIshaOffset:(int)n;

- (void)setLatitude:(double)n;
- (void)setLongitude:(double)n;
- (void)setAltitude:(double)n;
- (void)setMadhab:(int)n;
- (void)setMethod:(int)n;
- (void)setCustomSunriseAngle:(float)n;
- (void)setCustomSunsetAngle:(float)n;

- (void)setSystemTimezone:(BOOL)systemTZ;
- (void)setTimezone:(float)tz;
- (void)setDaylightSavings:(BOOL)dst;

- (void)calcTimes:(NSDate *)calcDate;

- (NSDate *)getFajrTime;
- (NSDate *)getShuruqTime;
- (NSDate *)getDhuhurTime;
- (NSDate *)getAsrTime;
- (NSDate *)getMaghribTime;
- (NSDate *)getIshaTime;

- (void)setDate:(NSDate *)date;
- (NSDate *)getDate;

@end
