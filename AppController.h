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
	
	IBOutlet NSWindow *welcomeWindow;	
	
	IBOutlet NSTextField *cityText;
	IBOutlet NSTextField *stateText;
	IBOutlet NSTextField *countryText;
	
	IBOutlet NSButton *toggleStartatlogin;
	
	
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
	NSString *adhanFile;
	BOOL userAdhan;
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
	BOOL tahajudReminder;
	int minutesBeforeTahajud;
}

- (IBAction)doNothing:(id)sender; 
- (IBAction)stopAdhan:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)getHelp:(id)sender;

- (void) handleTimer;

- (void) initPrayers;
- (void) initGui;
- (void) initPrayerItems;
- (void) setPrayerTimes;
- (void) loadDefaults;
- (void) checkPrayerTimes;
- (void) setStatusIcons;
- (void) setMenuBar: (BOOL) currentlyPrayerTime;

- (void) applyPrefs;

- (void) checkForUpdate:(BOOL)quiet;

- (IBAction)startAtLogin:(id)sender;

- (IBAction)openAboutPanel:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;

- (BOOL) isAdhanPlaying;

+ (AppController*) sharedController;


/* GROWL METHODS */

- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier;
- (void) growlNotificationWasClicked:(id)clickContext;
 - (BOOL) isGrowlInstalled;

@end
