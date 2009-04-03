//
//  AppController.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl-WithInstaller/Growl.h>
#import <QTKit/QTKit.h>
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
	IBOutlet NSMenuItem *hijriItem;
	IBOutlet NSMenuItem *fajrItem;
	IBOutlet NSMenuItem *shuruqItem;
	IBOutlet NSMenuItem *dhuhurItem;
	IBOutlet NSMenuItem *asrItem;
	IBOutlet NSMenuItem *maghribItem;
	IBOutlet NSMenuItem *ishaItem;
	NSMenuItem *muteAdhan;
	
	PrayerTimes *todaysPrayerTimes;
	PrayerTimes *tomorrowsPrayerTimes;
	NSDate *fajrTime;
	NSDate *shuruqTime;
	NSDate *dhuhurTime;
	NSDate *asrTime;
	NSDate *maghribTime;
	NSDate *ishaTime;
	NSDate *tomorrowFajrTime;
	NSDate *fajrReminderTime;
	NSDate *shuruqReminderTime;
	
	int currentDay;
	NSDate *lastAdhanAlert;
	NSDate *lastGrowlAlert;
	NSTimer *timer;
	QTMovie *adhan;
	int currentAdhan;
	BOOL adhanIsPlaying;
	NSArray *adhanList;
	NSDictionary *menuBarAttributes;	
	NSCalendar *islamicCalendar;
	
	
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
	int hijriOffset;
	
	
	BOOL silentMode;
	
	//fajr alert options
	int fajrAdhanOption;
	BOOL fajrAdhanUserSound;
	NSString *fajrAdhanUserSoundFile;

	//dhuhur alert options
	int dhuhurAdhanOption;
	BOOL dhuhurAdhanUserSound;
	NSString *dhuhurAdhanUserSoundFile;
	
	//asr alert options
	int asrAdhanOption;
	BOOL asrAdhanUserSound;
	NSString *asrAdhanUserSoundFile;
	
	//maghrib alert options
	int maghribAdhanOption;
	BOOL maghribAdhanUserSound;
	NSString *maghribAdhanUserSoundFile;
	
	//isha alert options
	int ishaAdhanOption;
	BOOL ishaAdhanUserSound;
	NSString *ishaAdhanUserSoundFile;
	
	//shuruq reminder alert options
	int shuruqReminderAdhanOption;
	BOOL shuruqReminderAdhanUserSound;
	NSString *shuruqReminderAdhanUserSoundFile;
	
	//fajr reminder alert options
	int fajrReminderAdhanOption;
	BOOL fajrReminderAdhanUserSound;
	NSString *fajrReminderAdhanUserSoundFile;
	
	float adhanVolume;
	
	BOOL fajrReminder;
	int minutesBeforeFajr;
	BOOL shuruqReminder;
	int minutesBeforeShuruq;
	BOOL enableGrowl;
	BOOL stickyGrowl;
	BOOL pauseItunesPref;
	
	//current values
	BOOL userSound;
	NSString *userSoundFile;
	int adhanOption;
	NSURL *adhanFile;
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

- (void) playAdhan:(int)prayerIndex;
- (BOOL) isAdhanPlaying;
- (void) stopAdhan;
- (void) pauseItunes;

- (void) loadPreferences;
- (void) applyPrefs;
- (BOOL) clockShows24Hr;


- (void) checkForUpdate:(BOOL)quiet;
- (NSString *) getVersion;
- (int) getBuildNumber;


/* USER ACTIONS */
- (IBAction) doNothing:(id)sender; 
- (IBAction) openAboutPanel:(id)sender;
- (IBAction) openPreferencesWindow:(id)sender;


/* GROWL METHODS */
- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier;
- (void) growlNotificationWasClicked:(id)clickContext;
- (BOOL) isGrowlInstalled;

- (NSString *) hijriDate;
- (void)soundDidEnd:(id) notification;


@end
