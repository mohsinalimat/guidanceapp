//
//  PrefController.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "AppController.h"

@interface PrefController : DBPrefsWindowController {

	/*********/
	/* VIEWS */
	/*********/
    IBOutlet NSView *calculationsPrefsView;
	IBOutlet NSView *locationPrefsView;
    IBOutlet NSView *soundPrefsView;
	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *advancedPrefsView;
	
	/***********/
	/* GENERAL */
	/***********/
	IBOutlet NSButton *displayNextPrayer;
	IBOutlet NSPopUpButton *displayNextPrayerName;
	IBOutlet NSTextField *displayNextPrayerNameTitleText;
	IBOutlet NSPopUpButton *displayNextPrayerTime;
	IBOutlet NSTextField *displayNextPrayerTimeTitleText;
	IBOutlet NSButton *displayIcon;
	IBOutlet NSButton *startAtLogin;
	IBOutlet NSButton *checkForUpdates;	
	
	/************/
	/* LOCATION */
	/************/
	IBOutlet NSTextField *location;
	IBOutlet NSButton *setLocation;
	IBOutlet NSImageView *lookupStatusImage;
	IBOutlet NSProgressIndicator *lookupIndicator;
	IBOutlet NSButton *systemTimezone;
	IBOutlet NSButton *daylightSavings;
	IBOutlet NSPopUpButton *timezone;
	NSArray *timezoneArray;
	
	/****************/
	/* PRAYER TIMES */
	/****************/
	IBOutlet NSWindow *customMethodSheet;
	IBOutlet NSPopUpButton *method;
	IBOutlet NSTextField *sunriseAngle;
	IBOutlet NSTextField *sunsetAngle;
	
	/**********/
	/* ALERTS */
	/**********/
	
	NSPopUpButton *adhanOption;
	NSButton *adhanPreview;
	NSString *prayerAdhanKey;
	NSString *customAdhanKey;
	NSString *customAdhanFileKey;
	NSNumber *tempSelection;
	
	NSMutableArray *playingStatus;
	BOOL playingPreview;
	NSSound *sound;
	
	IBOutlet NSButton *enableSilent;
	
	IBOutlet NSPopUpButton *fajrAdhanOption;
    IBOutlet NSButton *fajrAdhanPreview;
	IBOutlet NSPopUpButton *dhuhurAdhanOption;
    IBOutlet NSButton *dhuhurAdhanPreview;
	IBOutlet NSPopUpButton *asrAdhanOption;
    IBOutlet NSButton *asrAdhanPreview;
	IBOutlet NSPopUpButton *maghribAdhanOption;
    IBOutlet NSButton *maghribAdhanPreview;	
	IBOutlet NSPopUpButton *ishaAdhanOption;
    IBOutlet NSButton *ishaAdhanPreview;
	
	IBOutlet NSTextField *fajrAdhanTitleText;
	IBOutlet NSTextField *dhuhurAdhanTitleText;
	IBOutlet NSTextField *asrAdhanTitleText;
	IBOutlet NSTextField *maghribAdhanTitleText;
	IBOutlet NSTextField *ishaAdhanTitleText;
	
	IBOutlet NSButton *shuruqReminder;
	IBOutlet NSTextField *minutesBeforeShuruq;
	IBOutlet NSTextField *minutesBeforeShuruqText;
	IBOutlet NSPopUpButton *shuruqReminderAdhanOption;
    IBOutlet NSButton *shuruqReminderAdhanPreview;
	
	IBOutlet NSButton *fajrReminder;
	IBOutlet NSTextField *minutesBeforeFajr;
	IBOutlet NSTextField *minutesBeforeFajrText;
	IBOutlet NSPopUpButton *fajrReminderAdhanOption;
    IBOutlet NSButton *fajrReminderAdhanPreview;

	IBOutlet NSButton *pauseItunes;
	IBOutlet NSButton *enableGrowl;	
	IBOutlet NSButton *stickyGrowl;
	
	
	/********/
	/* MISC */
	/********/
	NSUserDefaults *userDefaults;
	NSFileManager *fileManager;
}


/* UI FUNCTIONS */
- (IBAction) showWindow:(id)sender;
- (void) awakeFromNib;
- (void) setupToolbar;
- (void) windowDidLoad;


/* GENERAL FUNCTIONS */
- (IBAction) displayNextPrayerToggle:(id)sender;
- (IBAction) selectDisplayNextPrayerOption:(id)sender;
- (IBAction) displayIconToggle:(id)sender;
- (IBAction) startAtLoginToggle:(id)sender;
- (IBAction) checkForUpdates:(id)sender;
- (BOOL) startsAtLogin;


/* LOCATION FUNCTIONS */
- (IBAction) lookupLocation:(id)sender;
- (IBAction) systemTimezoneToggle:(id)sender;
- (IBAction) selectTimezone:(id)sender;
- (void) locationSearch;


/* PRAYER TIME FUNCTIONS */
- (IBAction) selectMethod:(id)sender;
- (IBAction) saveCustomMethod: (id)sender;
- (IBAction) cancelCustomMethod: (id)sender;
- (IBAction) getMethodHelp: (id)sender;
- (void) customMethodClosed:(NSWindow *)sheet;
- (void) insertCustomMethod;


/* ALERT FUNCTIONS */
- (void) setAlertGlobals:(int)prayer;

- (IBAction) shuruqReminderToggle:(id)sender;
- (IBAction) fajrReminderToggle:(id)sender;
- (IBAction) enableGrowlToggle:(id)sender;
- (IBAction) enableSilentModeToggle:(id)sender;

- (IBAction) previewFajr:(id)sender;
- (IBAction) previewDhuhur:(id)sender;
- (IBAction) previewAsr:(id)sender;
- (IBAction) previewMaghrib:(id)sender;
- (IBAction) previewIsha:(id)sender;
- (IBAction) previewShuruqReminder:(id)sender;
- (IBAction) previewFajrReminder:(id)sender;
- (void) playPreview:(int)prayer;
- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful;
- (void) resetPreviewButtons;

- (IBAction) selectFajrAdhan:(id)sender;
- (IBAction) selectDhuhurAdhan:(id)sender;
- (IBAction) selectAsrAdhan:(id)sender;
- (IBAction) selectMaghribAdhan:(id)sender;
- (IBAction) selectIshaAdhan:(id)sender;
- (IBAction) selectShuruqReminderAdhan:(id)sender;
- (IBAction) selectFajrReminderAdhan:(id)sender;

- (void) selectCustomAdhan;
- (void) selectAdhanClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info;
- (void) insertCustomAdhan: (NSString *)fileName toAdhanOption: (NSPopUpButton *) adhanOption;
- (void) restoreCustomAdhans;


/* MISC FUNCTIONS */
- (IBAction) applyChange:(id)sender;
- (void) saveAndApply;


@end