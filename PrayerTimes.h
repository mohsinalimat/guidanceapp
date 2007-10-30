//
//  PrayerTimes.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
 
#import <Cocoa/Cocoa.h>


@interface PrayerTimes : NSObject {
	double Latitude;
	double Longitude;
	double Altitude;
	int Shafi;
	int TwilightDawnAngle;
	int TwilightSunsetAngle;
	
	NSCalendarDate *FajrTime;
	NSCalendarDate *ShuruqTime;
	NSCalendarDate *DhuhurTime;
	NSCalendarDate *AsrTime;
	NSCalendarDate *MaghribTime;
	NSCalendarDate *IshaTime;
}

- (void)setLatitude:(double)n;
- (void)setLongitude:(double)n;
- (void)setAltitude:(double)n;

- (void)calcTimes:(NSCalendarDate *)calcDate;

- (NSCalendarDate *)getFajrTime;

- (NSCalendarDate *)getShuruqTime;

- (NSCalendarDate *)getDhuhurTime;

- (NSCalendarDate *)getAsrTime;

- (NSCalendarDate *)getMaghribTime;

- (NSCalendarDate *)getIshaTime;

@end
