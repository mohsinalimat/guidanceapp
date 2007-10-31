#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface PrefController : DBPrefsWindowController {
    IBOutlet NSView *generalPrefsView;
    IBOutlet NSView *soundPrefsView;
    IBOutlet NSButton *previewButton;
	BOOL previewState;
}

@end
