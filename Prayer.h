//
//  Prayer.h
//  Guidance
//
//  Created by Matthew Crenshaw on 10/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <time.h>


@interface Prayer : NSObject
{
	@private
	NSString *PrayerName;
	NSCalendarDate *PrayerTime;
}

- (void) setTime : (NSCalendarDate *) prayerTime;
- (NSCalendarDate *) getTime;
- (void) setName : (NSString *) prayerName;
- (NSString *) getName;

- (NSString *) getFormattedTime;

@end
