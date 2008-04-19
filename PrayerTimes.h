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
	int Shafi;
	double TwilightDawnAngle;
	double TwilightSunsetAngle;
	float timezone;

	int FajrOffset;
	int ShuruqOffset;
	int DhuhurOffset;
	int AsrOffset;
	int MaghribOffset;
	int IshaOffset;
	
	
	NSCalendarDate *FajrTime;
	NSCalendarDate *ShuruqTime;
	NSCalendarDate *DhuhurTime;
	NSCalendarDate *AsrTime;
	NSCalendarDate *MaghribTime;
	NSCalendarDate *IshaTime;
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
- (void)setAsrMethod:(int)n;
- (void)setIshaMethod:(int)n;
- (void)setFajrMethod:(int)n;

- (void)calcTimes:(NSCalendarDate *)calcDate;

- (NSCalendarDate *)getFajrTime;

- (NSCalendarDate *)getShuruqTime;

- (NSCalendarDate *)getDhuhurTime;

- (NSCalendarDate *)getAsrTime;

- (NSCalendarDate *)getMaghribTime;

- (NSCalendarDate *)getIshaTime;

@end
