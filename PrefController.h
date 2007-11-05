#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "AppController.h"

@interface PrefController : DBPrefsWindowController {
    IBOutlet NSView *generalPrefsView;
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
	BOOL previewState;
	NSSound *sound;
}
- (IBAction)preview_clicked:(id)sender;
- (IBAction)sound_toggle:(id)sender;
- (void)windowWillClose:(NSNotification *)notification;
@end
