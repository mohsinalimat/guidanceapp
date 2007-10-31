#import "PrefController.h"

@implementation PrefController

- (id)initWithWindow:(NSWindow *)window
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
		switch ([selectSound indexOfSelectedItem])
		{
			case 1:		sound = [NSSound soundNamed:@"alaqsa"]; break;
			case 2:		sound = [NSSound soundNamed:@"istanbul"]; break;
			case 3:		sound = [NSSound soundNamed:@"yusufislam"]; break;
			case 0:
			default:	sound = [NSSound soundNamed:@"makkah"]; break;
		}
		
		NSLog(@"INDEX: %d", [selectSound indexOfSelectedItem]);
		[sound play];
			// change button text to "Stop"
		[previewButton setTitle:@"Stop"];
		previewState = !previewState;
	}
	else
	{
			// stop sound
		[sound stop];
			// change button text to "Preview"
		[previewButton setTitle:@"Preview"];
		previewState = !previewState;
	}
}

@end
