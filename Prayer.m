//
//  Prayer.m
//  Guidance
//
//  Created by Matthew Crenshaw on 10/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Prayer.h"


@implementation Prayer

- (void) setTime: (NSCalendarDate *) prayerTime
{
	PrayerTime = prayerTime;
}

- (NSCalendarDate *) getTime
{
	return PrayerTime;
}

- (NSString *) getFormattedTime
{
	return [PrayerTime descriptionWithCalendarFormat: @"%1I:%M %p"];
}

- (void) setName: (NSString *) prayerName
{
	PrayerName = prayerName;
}

- (NSString *) getName
{
	return PrayerName;
}

@end
