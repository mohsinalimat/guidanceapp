//
//  AppController.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growler.h"
#import "Prayer.h"
#import "PrayerTimes.h"
#import "PrefController.h"

@interface AppController : NSObject
{	

	/* GUI */
	NSStatusItem *menuBar;
    
	IBOutlet NSMenu *appMenu;
	
	IBOutlet NSMenuItem *fajrItem;
	IBOutlet NSMenuItem *shuruqItem;
	IBOutlet NSMenuItem *dhuhurItem;
	IBOutlet NSMenuItem *asrItem;
	IBOutlet NSMenuItem *maghribItem;
	IBOutlet NSMenuItem *ishaItem;
	
	IBOutlet NSWindow *aboutGuidance;
	
	IBOutlet NSTextField *guidanceVersion;
	
	
	/* PRAYER OBJECTS */
	Prayer *fajrPrayer;
	Prayer *shuruqPrayer;
	Prayer *dhuhurPrayer;
	Prayer *asrPrayer;
	Prayer *maghribPrayer;
	Prayer *ishaPrayer;
	
	Prayer *nextPrayer;
	
	PrayerTimes *todaysPrayerTimes;
	
	
	/* NOTIFICATION */
	Growler *MyGrowler;
	
	NSTimer *timer;
	NSCalendarDate *lastCheckTime;
	NSCalendarDate *prayerTimeDate;
	
	
	
	/* PREFERENCES */
	NSString *adhanFile;
	BOOL displayGrowl;
	BOOL stickyGrowl;
}

- (IBAction)doNothing:(id)sender; 
- (IBAction)selectPrayer:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)website:(id)sender;
- (IBAction)openAboutPanel:(id)sender;

- (void) handleTimer;

- (void) initPrayers;
- (void) initGui;
- (void) initPrayerItems;
- (void) setPrayerTimes;
- (void) loadDefaults;
- (void) checkPrayerTimes;

- (IBAction)openPreferencesWindow:(id)sender;

@end
