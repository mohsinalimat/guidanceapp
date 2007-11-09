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
	
	IBOutlet NSWindow *aboutGuidance;
	IBOutlet NSWindow *welcomeWindow;
	
	IBOutlet NSTextField *guidanceVersion;
	
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
	BOOL checkForUpdates;
	BOOL firstRun;
	NSString *currentVersion;
	int menuDisplayTime;
	int menuDisplayName;
	BOOL displayIcon;
}

- (IBAction)doNothing:(id)sender; 
- (IBAction)selectPrayer:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)website:(id)sender;
- (IBAction)openAboutPanel:(id)sender;
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
