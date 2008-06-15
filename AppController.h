//
//  AppController.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl-WithInstaller/Growl.h>
#import "Prayer.h"
#import "PrayerTimes.h"
#import "PrefController.h"
#import "AboutController.h"
#import "WelcomeController.h"

#define NotificationName  @"Guidance Notification"

@interface AppController : NSObject <GrowlApplicationBridgeDelegate>
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
	NSMenuItem *muteAdhan;
	NSMenuItem *muteSeperator;
	NSDictionary *menuItems;
	NSDictionary *prayersArray;
	
	
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
	NSTimer *timer;
	NSCalendarDate *lastCheckTime;
	NSCalendarDate *lastNotificationTime;
	NSCalendarDate *prayerTimeDate;
	NSSound *adhan;
	NSString *currentlyPlayingAdhan;
	
	
	/* PREFERENCES */
	NSUserDefaults *userDefaults;
	NSArray *adhanOptions;
	
	BOOL userPrefsCheckForUpdates;
	BOOL userPrefsdisplayIcon;
	BOOL userPrefsDisplayNextPrayer;
	int userPrefsDisplayNextPrayerName;
	int userPrefsDisplayNextPrayerTime;
	BOOL userPrefsEnableGrowl;
	BOOL userPrefsEnableSound;
	BOOL userPrefsFajrReminder;
	BOOL userPrefsFirstRun;
	int userPrefsMinutesBeforeFajr;
	int userPrefsMinutesBeforeShuruq;
	BOOL userPrefsShuruqReminder;
	int userPrefsSoundFile;
	BOOL userPrefsStickyGrowl;
	BOOL userPrefsUserSound;
	NSString *userPrefsUserSoundFile;
	
	NSString *adhanFile; /* DONE */
	BOOL userAdhan; /* DONE */
	BOOL displayGrowl; /* DONE */
	BOOL stickyGrowl; /* DONE */
	BOOL checkForUpdates; /* DONE */
	BOOL firstRun; /* DONE */
	int menuDisplayTime; /* DONE */
	int menuDisplayName; /* DONE */
	BOOL displayIcon; /* DONE */
	BOOL displayNextPrayer; /* DONE */
	BOOL shuruqReminder; /* DONE */
	int minutesBeforeShuruq; /* DONE */
	BOOL tahajudReminder; /* DONE */
	int minutesBeforeTahajud; /* DONE */
}


+ (AppController*) sharedController;


/* APP STARTUP */
- (void) initPrayers;
- (void) setPrayerTimes;
- (void) initAppMenu;
- (void) setMenuTimes;

- (void) loadDefaults;
- (void) applyPrefs;


/* APP ACTIONS */
- (void) runLoop;
- (void) checkPrayerTimes;
- (void) setStatusIcons;
- (void) setMenuBar: (BOOL) currentlyPrayerTime;
- (void) checkForUpdate:(BOOL)quiet;
- (NSString *) getVersion;
- (int) getBuildNumber;
- (BOOL) isAdhanPlaying;


/* USER ACTIONS */
- (IBAction)doNothing:(id)sender; 
- (IBAction)stopAdhan:(id)sender;
- (IBAction)getHelp:(id)sender;
- (IBAction)openAboutPanel:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;


/* GROWL METHODS */
- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier;
- (void) growlNotificationWasClicked:(id)clickContext;
- (BOOL) isGrowlInstalled;



@end
