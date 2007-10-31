#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface PrefController : DBPrefsWindowController {
    IBOutlet NSView *generalPrefsView;
    IBOutlet NSView *soundPrefsView;
    IBOutlet NSButton *previewButton;
    IBOutlet NSPopUpButton *selectSound;
	BOOL previewState;
	NSSound *sound;
}
- (IBAction)preview_clicked:(id)sender;
@end
