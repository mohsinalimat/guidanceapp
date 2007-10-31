#import "PrefController.h"

@implementation PrefController

- (id)initWithWindow:(NSWindow *)window
  // -initWithWindow: is the designated initializer for NSWindowController.
{
	self = [super initWithWindow:nil];
	if (self != nil) {
		previewState = NO;
	}
	return self;

	(void)window;  // To prevent compiler warnings.
}

- (void)setupToolbar
{
  [self addView:generalPrefsView label:@"General"];
  [self addView:soundPrefsView label:@"Sound"];
}

- (IBAction)preview_clicked:(id)sender
{
	if (!previewState)
	{
			// play sound
		//cmd!
			// change button text to "Stop"
		[previewButton setTitle:@"Stop"];
		previewState = !previewState;
	}
	else
	{
			// stop sound
		//cmd!
			// change button text to "Preview"
		[previewButton setTitle:@"Preview"];
		previewState = !previewState;
	}
}

@end
