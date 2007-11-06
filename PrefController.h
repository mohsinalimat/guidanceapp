#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "AppController.h"

@interface PrefController : DBPrefsWindowController {
    IBOutlet NSView *calculationsPrefsView;
	IBOutlet NSView *locationPrefsView;
    IBOutlet NSView *soundPrefsView;
    IBOutlet NSButton *previewButton;
    IBOutlet NSPopUpButton *selectSound;
    IBOutlet NSButton *playAsr;
    IBOutlet NSButton *playDhuhur;
    IBOutlet NSButton *playFajr;
    IBOutlet NSButton *playIsha;
    IBOutlet NSButton *playMaghrab;
    IBOutlet NSButton *playShuruq;
    IBOutlet NSButton *toggleSound;
	IBOutlet NSButton *toggleManual;
	IBOutlet NSTextField *latitudeText;
	IBOutlet NSTextField *longitudeText;
	IBOutlet NSTextField *cityText;
	IBOutlet NSTextField *stateText;
	IBOutlet NSTextField *countryText;
	IBOutlet NSButton *lookupLocation;
	BOOL previewState;
	NSSound *sound;
}
- (IBAction)preview_clicked:(id)sender;
- (IBAction)sound_toggle:(id)sender;
- (IBAction)manual_toggle:(id)sender;
- (IBAction)lookup_location:(id)sender;

- (IBAction)showWindow:(id)sender;

- (void)windowWillClose:(NSNotification *)notification;
@end
