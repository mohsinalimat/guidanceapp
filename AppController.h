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
#import "AboutController.h"

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
	NSDictionary *menuItems;
	NSDictionary *prayersArray;
	
	IBOutlet NSWindow *welcomeWindow;	
	
	IBOutlet NSTextField *cityText;
	IBOutlet NSTextField *stateText;
	IBOutlet NSTextField *countryText;
	
	
	
	/* PRAYER OBJECTS */
	Prayer *fajrPrayer;
	Prayer *shuruqPrayer;
	Prayer *dhuhurPrayer;
	Prayer *asrPrayer;
	Prayer *maghribPrayer;
	Prayer *ishaPrayer;
	Prayer *tomorrowFajrPrayer;
	
	Prayer *nextPrayer;
	Prayer *currentPrayer;
	
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
	BOOL checkForUpdates;
	BOOL firstRun;
	NSString *currentVersion;
	int menuDisplayTime;
	int menuDisplayName;
	BOOL displayIcon;
	BOOL displayNextPrayer;
	BOOL shuruqReminder;
	int minutesBeforeShuruq;
}

- (IBAction)doNothing:(id)sender; 
- (IBAction)stopAdhan:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)getHelp:(id)sender;
- (IBAction)firstRunSetup:(id)sender;

- (void) handleTimer;

- (void) initPrayers;
- (void) initGui;
- (void) initPrayerItems;
- (void) setPrayerTimes;
- (void) loadDefaults;
- (void) checkPrayerTimes;

- (void) applyPrefs;

- (void) checkForUpdate:(BOOL)quiet;

- (IBAction)openPreferencesWindow:(id)sender;

+ (AppController*) sharedController;

@end
