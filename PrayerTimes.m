//
//  PrayerTimes.m
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PrayerTimes.h"


@implementation PrayerTimes
 
- (NSCalendarDate *)getFajrTime 
{
	NSCalendarDate *fajrTime = [NSCalendarDate calendarDate];
	return fajrTime;
}


- (NSCalendarDate *)getShuruqTime 
{
	NSCalendarDate *shuruqTime = [NSCalendarDate calendarDate];
	return shuruqTime;
}


- (NSCalendarDate *)getDhuhurTime 
{
	NSCalendarDate *dhuhurTime = [NSCalendarDate calendarDate];
	return dhuhurTime;
}


- (NSCalendarDate *)getAsrTime 
{
	NSCalendarDate *asrTime = [NSCalendarDate calendarDate];
	return asrTime;
}


- (NSCalendarDate *)getMaghribTime 
{
	NSCalendarDate *maghribTime = [NSCalendarDate calendarDate];
	return maghribTime;
}


- (NSCalendarDate *)getIshaTime 
{
	NSCalendarDate *ishaTime = [NSCalendarDate calendarDate];
	return ishaTime;
}



@end
