//
//  PrayerTimes.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrayerTimes : NSObject {
	int theNumber;
}

- (int)getNumber;
- (void)setNumber:(int)number;
@end
