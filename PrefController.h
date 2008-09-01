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
	
	/********/
	/* MISC */
	/********/
	NSUserDefaults *userDefaults;
	NSFileManager *fileManager;
}


/* UI FUNCTIONS */
- (IBAction)showWindow:(id)sender;
- (void)awakeFromNib;
- (void)setupToolbar;
- (void)windowDidLoad;


/* GENERAL FUNCTIONS */
- (IBAction)displayNextPrayerToggle:(id)sender;
- (IBAction)selectDisplayNextPrayerOption:(id)sender;
- (IBAction)displayIconToggle:(id)sender;
- (IBAction)startAtLoginToggle:(id)sender;
- (IBAction)checkForUpdates:(id)sender;
- (BOOL)startsAtLogin;


/* LOCATION FUNCTIONS */
- (IBAction)lookupLocation:(id)sender;
- (IBAction)systemTimezoneToggle:(id)sender;
- (IBAction)selectTimezone:(id)sender;
- (void)locationSearch;


/* PRAYER TIME FUNCTIONS */
- (IBAction)selectMethod:(id)sender;
- (IBAction)saveCustomMethod: (id)sender;
- (IBAction)cancelCustomMethod: (id)sender;
- (IBAction)getMethodHelp: (id)sender;
- (void)customMethodClosed:(NSWindow *)sheet;
- (void)insertCustomMethod;


/* ALERT FUNCTIONS */
- (IBAction)shuruqReminderToggle:(id)sender;
- (IBAction)fajrReminderToggle:(id)sender;
- (IBAction)enableGrowlToggle:(id)sender;
- (IBAction)enableSoundToggle:(id)sender;
- (IBAction)playPreview:(id)sender;
- (IBAction)selectAdhan:(id)sender;
- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful;
- (void) selectAdhanClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info;
- (void) insertUserAdhan:(NSString *) userSoundFileName;


/* MISC FUNCTIONS */
- (IBAction)applyChange:(id)sender;
- (void)saveAndApply;



@end


