//
//  Prayer.m
//  Guidance
//
//  Created by Matthew Crenshaw on 10/22/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "Prayer.h"


@implementation Prayer

- (void) setTime: (NSCalendarDate *) prayerTime
{
	[prayerTime retain];
    [PrayerTime release];
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

- (void) setPlayAudio: (BOOL) playAudio
{
	PlayAudio = playAudio;
}

- (BOOL) getPlayAudio {
	return PlayAudio;
}

- (id)init
{
    self = [super init];
    if (self) {
        PrayerName = @"";
        PrayerTime = [[NSCalendarDate calendarDate] retain];
    }
    return self;
}

@end
