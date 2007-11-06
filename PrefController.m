#import "PrefController.h"

@implementation PrefController

- (void)setupToolbar
{
	[self addView:locationPrefsView label:@"Location"];
	[self addView:calculationsPrefsView label:@"Calculations"];
	[self addView:soundPrefsView label:@"Sound"];
}

- (IBAction)sound_toggle:(id)sender
{
    if ([toggleSound state] == NSOffState)
	{
		[previewButton setEnabled:NO];
		[selectSound setEnabled:NO];
		[playAsr setEnabled:NO];
		[playDhuhur setEnabled:NO];
		[playFajr setEnabled:NO];
		[playIsha setEnabled:NO];
		[playMaghrab setEnabled:NO];
		[playShuruq setEnabled:NO];
	}
	else
	{
		[previewButton setEnabled:YES];
		[selectSound setEnabled:YES];
		[playAsr setEnabled:YES];
		[playDhuhur setEnabled:YES];
		[playFajr setEnabled:YES];
		[playIsha setEnabled:YES];
		[playMaghrab setEnabled:YES];
		[playShuruq setEnabled:YES];
	}
}

- (IBAction)manual_toggle:(id)sender
{
    if ([toggleManual state] == NSOffState)
	{
		[latitudeText setEnabled:NO];
		[longitudeText setEnabled:NO];
		[cityText setEnabled:YES];
		[stateText setEnabled:YES];
		[countryText setEnabled:YES];
	}
	else
	{
		[latitudeText setEnabled:YES];
		[longitudeText setEnabled:YES];
		[cityText setEnabled:NO];
		[stateText setEnabled:NO];
		[countryText setEnabled:NO];
	}
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

- (IBAction)lookup_location:(id)sender
{
	NSString *city = [cityText stringValue];
	NSString *state = [stateText stringValue];
	NSString *country = [countryText stringValue];
		
	NSString *safeCity =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) city, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	NSString *safeState =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) state, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	NSString *safeCountry =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) country, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://guidanceapp.com/location.php?city=%@&state=%@&country=%@",safeCity,safeState,safeCountry];
	NSDictionary *coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	BOOL valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	
	if (valid)
	{
		NSLog(@"Valid lookup!");
		[latitudeText setFloatValue: [[coordDict valueForKey:@"latitude"] doubleValue]];
		[longitudeText setFloatValue: [[coordDict valueForKey:@"longitude"] doubleValue]];
	}
	else
	{
		NSLog(@"Invalid lookup...");
		//error msg
	}
	
	[self crossFadeView:locationPrefsView withView:locationPrefsView];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[self sound_toggle:nil];
	[self manual_toggle:nil];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[[self window] setDelegate:self];
	previewState = NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[[AppController sharedController] applyPrefs];
}

@end
