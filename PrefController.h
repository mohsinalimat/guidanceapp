#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "AppController.h"

@interface PrefController : DBPrefsWindowController {
    IBOutlet NSView *calculationsPrefsView;
	IBOutlet NSView *locationPrefsView;
    IBOutlet NSView *soundPrefsView;
	IBOutlet NSView *generalPrefsView;
	
    IBOutlet NSButton *previewButton;
    IBOutlet NSPopUpButton *selectSound;
    IBOutlet NSButton *playAsr;
    IBOutlet NSButton *playDhuhur;
    IBOutlet NSButton *playFajr;
    IBOutlet NSButton *playIsha;
    IBOutlet NSButton *playMaghrab;
	
    IBOutlet NSButton *toggleSound;
	IBOutlet NSButton *toggleManual;
	IBOutlet NSButton *toggleStartatlogin;
	IBOutlet NSButton *toggleGrowl;
	IBOutlet NSButton *toggleNextPrayer;
	IBOutlet NSButton *toggleDisplayIcon;
	IBOutlet NSButton *toggleShuruq;		
	IBOutlet NSPopUpButton *selectDisplayName;
	IBOutlet NSPopUpButton *selectDisplayTime;
	
	IBOutlet NSButton *stickyButton;
	IBOutlet NSTextField *latitudeText;
	IBOutlet NSTextField *longitudeText;
	IBOutlet NSTextField *cityText;
	IBOutlet NSTextField *stateText;
	IBOutlet NSTextField *countryText;
	IBOutlet NSButton *lookupLocation;
	IBOutlet NSWindow *lookupProgress;
	IBOutlet NSTextField *lookupStatus;
	IBOutlet NSTextField *currentLocation;
	IBOutlet NSTextField *minutesBeforeShuruq;
	IBOutlet NSTextField *minutesBeforeShuruqText;	
	IBOutlet NSProgressIndicator *lookupIndicator;
	BOOL previewState;
	NSSound *sound;
	
	NSUserDefaults *userDefaults;
}
- (IBAction)startatlogin_toggle:(id)sender;
- (IBAction)preview_clicked:(id)sender;
- (IBAction)sound_toggle:(id)sender;
- (IBAction)manual_toggle:(id)sender;
- (IBAction)growl_toggle:(id)sender;
- (IBAction)displaynextprayer_toggle:(id)sender;
- (IBAction)shuruq_toggle:(id)sender;

- (IBAction)lookup_location:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

- (IBAction)showWindow:(id)sender;

- (void)windowWillClose:(NSNotification *)notification;


@end
