#import "PrefController.h"

@implementation PrefController

- (void)setupToolbar
{
	[self addView:generalPrefsView label:@"General"];
	[self addView:locationPrefsView label:@"Location"];
	[self addView:calculationsPrefsView label:@"Prayer Times"];
	[self addView:soundPrefsView label:@"Alerts"];
}

- (IBAction)growl_toggle:(id)sender
{
    if ([toggleGrowl state] == NSOffState)
	{
		[stickyButton setEnabled:NO];
	} 
	else 
	{
		[stickyButton setEnabled:YES];	
	}
}

- (IBAction)displaynextprayer_toggle:(id)sender
{
    if ([toggleNextPrayer state] == NSOffState)
	{
		[toggleDisplayIcon setState:1];
		[toggleDisplayIcon setEnabled:NO];
		[selectDisplayName setEnabled:NO];
		[selectDisplayTime setEnabled:NO];
	} 
	else 
	{
		[toggleDisplayIcon setEnabled:YES];
		[selectDisplayName setEnabled:YES];
		[selectDisplayTime setEnabled:YES];
	}
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
		[lookupLocation setEnabled:YES];
	}
	else
	{
		[latitudeText setEnabled:YES];
		[longitudeText setEnabled:YES];
		[cityText setEnabled:NO];
		[stateText setEnabled:NO];
		[countryText setEnabled:NO];
		[lookupLocation setEnabled:NO];
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
	[lookupStatus setStringValue:@"Looking up latitude and longitude..."];
	[lookupIndicator startAnimation:sender];
	[lookupProgress makeKeyAndOrderFront:nil];
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
		[latitudeText setFloatValue: [[coordDict valueForKey:@"latitude"] doubleValue]];
		[longitudeText setFloatValue: [[coordDict valueForKey:@"longitude"] doubleValue]];
		
		[lookupStatus setStringValue:@"Your location has been set."];
		[lookupIndicator stopAnimation:sender];
		
		NSString *cityState = [[[[cityText stringValue] stringByAppendingString:@", "] stringByAppendingString:[stateText stringValue]] stringByAppendingString:@" "];
		[currentLocation setStringValue:[cityState stringByAppendingString:[countryText stringValue]]];
	}
	else
	{
		[lookupStatus setStringValue:@"Error: Unable to find location."];
		[lookupIndicator stopAnimation:sender];
	}
	
	[self crossFadeView:locationPrefsView withView:locationPrefsView];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[self sound_toggle:nil];
	[self manual_toggle:nil];
	[self displaynextprayer_toggle:nil];
	[self growl_toggle:nil];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[[self window] setDelegate:self];
	previewState = NO;
	
	[currentLocation setStringValue:[[[[[cityText stringValue] stringByAppendingString:@", "] stringByAppendingString:[stateText stringValue]] stringByAppendingString:@" "] stringByAppendingString:[countryText stringValue]]];	
}

- (void)windowWillClose:(NSNotification *)notification
{

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	[userDefaults setFloat:[latitudeText floatValue] forKey:@"Latitude"];
	[userDefaults setFloat:[longitudeText floatValue] forKey:@"Longitude"];
	
	if ([toggleNextPrayer state] == NSOffState) {
		[userDefaults setBool:YES forKey:@"DisplayIcon"];
	}

	[[AppController sharedController] applyPrefs];
}

- (IBAction)startatlogin_toggle:(id)sender
{
	int i = 0;
	NSMutableArray* loginItems;

    loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    loginItems =  [[loginItems autorelease] mutableCopy];
	
	NSMutableDictionary *loginObject = [[NSMutableDictionary alloc] initWithCapacity:2];

	if([toggleStartatlogin state] == NSOnState) {
	
		//add it to login items
		[loginObject setObject:[[NSBundle mainBundle] bundlePath] forKey:@"Path"];
		[loginItems addObject:loginObject];
		
	} else {
		
		//remove it from login items
		 for (i=0;i<[loginItems count];i++)
        {
            if ([[[loginItems objectAtIndex:i] objectForKey:@"Path"] isEqualToString:[[NSBundle mainBundle] bundlePath]])
                [loginItems removeObjectAtIndex:i];
        }
	}

    CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems, (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 
	CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

    [loginItems release];


}


- (IBAction)checkForUpdates:(id)sender
{
	[[AppController sharedController] checkForUpdate:NO];
}



@end
