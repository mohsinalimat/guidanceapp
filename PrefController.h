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
	IBOutlet NSView *advancedCalculationsPrefsView;
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
	
	/****************/
	/* CALCULATIONS */
	/****************/
	IBOutlet NSButton *expandAdvanced;	

	/************/
	/* LOCATION */
	/************/
	IBOutlet NSTextField *location;
	IBOutlet NSTextField *locationTitleText;
	IBOutlet NSButton *setLocation;
	IBOutlet NSTextField *lookupStatus;
	IBOutlet NSProgressIndicator *lookupIndicator;
	IBOutlet NSButton *manualLocation;
	IBOutlet NSTextField *latitude;
	IBOutlet NSTextField *latitudeLabel;
	IBOutlet NSTextField *longitude;
	IBOutlet NSTextField *longitudeLabel;
	IBOutlet NSButton *setManualLocation;
	
	/**********/
	/* ALERTS */
	/**********/
	IBOutlet NSButton *enableSound;
    IBOutlet NSPopUpButton *soundFile;
	IBOutlet NSTextField *soundFileTitleText;
    IBOutlet NSButton *previewSound;
	IBOutlet NSButton *playFajr;
	IBOutlet NSTextField *playFajrTitleText;	
    IBOutlet NSButton *playDhuhur;
	IBOutlet NSTextField *playDhuhurTitleText;
    IBOutlet NSButton *playAsr;
	IBOutlet NSTextField *playAsrTitleText;
    IBOutlet NSButton *playMaghrib;
	IBOutlet NSTextField *playMaghribTitleText;
    IBOutlet NSButton *playIsha;
	IBOutlet NSTextField *playIshaTitleText;
	IBOutlet NSButton *shuruqReminder;
	IBOutlet NSTextField *minutesBeforeShuruq;
	IBOutlet NSTextField *minutesBeforeShuruqText;	
	IBOutlet NSButton *fajrReminder;
	IBOutlet NSTextField *minutesBeforeFajr;
	IBOutlet NSTextField *minutesBeforeFajrText;
	IBOutlet NSButton *enableGrowl;	
	IBOutlet NSButton *stickyGrowl;
	BOOL playingPreview;
	NSSound *sound;


	NSUserDefaults *userDefaults;
	NSFileManager *fileManager;
}


/* UI FUNCTIONS */
- (void)awakeFromNib;
- (void)setupToolbar;
- (IBAction)showWindow:(id)sender;
- (void)windowDidLoad;


/* GENERAL FUNCTIONS */
- (IBAction)displayNextPrayerToggle:(id)sender;
- (IBAction)displayIconToggle:(id)sender;
- (IBAction)selectDisplayNextPrayerOption:(id)sender;
- (IBAction)startAtLoginToggle:(id)sender;
- (IBAction)checkForUpdates:(id)sender;


/* LOCATION FUNCTIONS */
- (IBAction)manualLocationToggle:(id)sender;
- (void)locationToggle;
- (IBAction)lookupLocation:(id)sender;


/* LOCATION FUNCTIONS */
- (IBAction)advancedToggle:(id)sender;


/* ALERT FUNCTIONS */
- (IBAction)shuruqReminderToggle:(id)sender;
- (IBAction)fajrReminderToggle:(id)sender;
- (IBAction)enableGrowlToggle:(id)sender;
- (IBAction)enableSoundToggle:(id)sender;
- (IBAction)playPreview:(id)sender;
- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful;
- (IBAction)selectAdhan:(id)sender;
- (void) selectAdhanClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info;
- (void) insertUserAdhan:(NSString *) userSoundFileName;

/* MISC FUNCTIONS */
- (IBAction)applyChange:(id)sender;
- (void)saveAndApply;



@end


