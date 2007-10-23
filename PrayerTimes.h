//
//  PrayerTimes.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
 
#import <Cocoa/Cocoa.h>


@interface PrayerTimes : NSObject {
	float latitude;
	float longitude;
}

- (void)setLatitude:(float)lat;
- (void)setLongitude:(float)lon;

- (NSCalendarDate *)getFajrTime;

- (NSCalendarDate *)getShuruqTime;

- (NSCalendarDate *)getDhuhurTime;

- (NSCalendarDate *)getAsrTime;

- (NSCalendarDate *)getMaghribTime;

- (NSCalendarDate *)getIshaTime;

@end
