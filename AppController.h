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
	
	PrayerTimes *todaysPrayerTimes;
	PrayerTimes *tomorrowsPrayerTimes;
	NSDate *fajrTime;
	NSDate *shuruqTime;
	NSDate *dhuhurTime;
	NSDate *asrTime;
	NSDate *maghribTime;
	NSDate *ishaTime;
	NSDate *tomorrowFajrTime;
	
	int currentDay;
	NSDate *lastCheckTime;
	NSTimer *timer;
	
	
	/* PREFERENCES */
	NSUserDefaults *userDefaults;
	BOOL firstRun;
	int preferencesVersion;
	BOOL checkForUpdates;
	BOOL displayIcon;
	BOOL displayNextPrayer;
	int displayNextPrayerName;
	int displayNextPrayerTime;
	float latitude;
	float longitude;
	BOOL systemTimezone;
	float timezone;
	BOOL daylightSavings;
	int madhab;
	int method;
	float customSunriseAngle;
	float customSunsetAngle;
	int fajrOffset;
	int shuruqOffset;
	int dhuhurOffset;
	int asrOffset;
	int maghribOffset;
	int ishaOffset;
	BOOL enableSound;
	int soundFile;
	BOOL userSound;
	NSString *userSoundFile;
	BOOL playAdhanForFajr;
	BOOL playAdhanForDhuhur;
	BOOL playAdhanForAsr;
	BOOL playAdhanForMaghrib;
	BOOL playAdhanForIsha;
	BOOL fajrReminder;
	int minutesBeforeFajr;
	BOOL shuruqReminder;
	int minutesBeforeShuruq;
	BOOL enableGrowl;
	BOOL stickyGrowl;
}


+ (AppController*) sharedController;

- (void) createAppMenu;
- (void) setPrayerTimes;
- (void) displayPrayerTimes;


- (void) runLoop;
- (void) checkPrayerStatus;
- (void) setMenuBarTitle;
- (NSString *) getTimeDisplay:(NSDate *)prayerTime;
- (NSString *) getNameDisplay:(NSString *)prayerName;
- (void) setStatusIcons;
- (void) checkPrayertimes;

- (void) loadPreferences;
- (void) applyPrefs;


- (void) checkForUpdate:(BOOL)quiet;
- (NSString *) getVersion;
- (int) getBuildNumber;


/* USER ACTIONS */
- (IBAction) stopAdhan:(id)sender;
- (IBAction) doNothing:(id)sender; 
- (IBAction) openAboutPanel:(id)sender;
- (IBAction) getHelp:(id)sender;
- (IBAction) openPreferencesWindow:(id)sender;


/* GROWL METHODS */
- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier;
- (void) growlNotificationWasClicked:(id)clickContext;
- (BOOL) isGrowlInstalled;



@end
