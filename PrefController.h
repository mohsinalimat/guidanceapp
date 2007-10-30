#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface PrefController : DBPrefsWindowController
{
  IBOutlet NSView *generalPrefsView;
  IBOutlet NSView *soundPrefsView;
}

@end
