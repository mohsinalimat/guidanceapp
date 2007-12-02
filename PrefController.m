#import "PrefController.h"

@implementation PrefController

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	[currentLocation setStringValue:[[[[[userDefaults valueForKey:@"SetCity"] stringByAppendingString:@", "] stringByAppendingString:[userDefaults valueForKey:@"SetState"]] stringByAppendingString:@" "] stringByAppendingString:[userDefaults valueForKey:@"SetCountry"]]];	
}

- (void)setupToolbar
{
	[self addView:generalPrefsView label:@"General"];
	[self addView:locationPrefsView label:@"Location"];
	[self addView:calculationsPrefsView label:@"Prayer Times"];
	[self addView:soundPrefsView label:@"Alerts"];
}

- (IBAction)shuruq_toggle:(id)sender
{
    if ([toggleShuruq state] == NSOffState)
	{
		[minutesBeforeShuruq setEnabled:NO];
	} 
	else 
	{
		[minutesBeforeShuruq setEnabled:YES];	
	}
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
		[minutesBeforeShuruq setEnabled:NO];
		[toggleShuruq setEnabled:NO];
		[minutesBeforeShuruqText setStringValue:@" minutes before"]; //set to grey text
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
		[minutesBeforeShuruq setEnabled:YES];
		[toggleShuruq setEnabled:YES];
		[minutesBeforeShuruqText setStringValue:@" minutes before"];
	}
}

- (IBAction)manual_toggle:(id)sender
{
    if ([toggleManual state] == NSOffState)
	{
		[latitudeText setEnabled:NO];
		[longitudeText setEnabled:NO];
		[setManualLocation setEnabled:NO];
		[cityText setEnabled:YES];
		[stateText setEnabled:YES];
		[countryText setEnabled:YES];
		[lookupLocation setEnabled:YES];
		[currentLocation setStringValue:[[[[[userDefaults valueForKey:@"SetCity"] stringByAppendingString:@", "] stringByAppendingString:[userDefaults valueForKey:@"SetState"]] stringByAppendingString:@" "] stringByAppendingString:[userDefaults valueForKey:@"SetCountry"]]];	
	}
	else
	{
		[latitudeText setEnabled:YES];
		[longitudeText setEnabled:YES];
		[setManualLocation setEnabled:YES];
		[cityText setEnabled:NO];
		[stateText setEnabled:NO];
		[countryText setEnabled:NO];
		[lookupLocation setEnabled:NO];
		
		[currentLocation setStringValue:[NSString stringWithFormat:@"Manually set to (%3.4f,%3.4f)",[userDefaults floatForKey:@"Latitude"],[userDefaults floatForKey:@"Longitude"]]];
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
		
		[sound setDelegate:self];
		[sound play];
		
		// change button text to "Stop"
		[previewButton setTitle:@"Stop"];
		previewState = !previewState;
	}
	else
	{
		// stop sound
		[sound stop];
	}
}

- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful
{
	[previewButton setTitle:@"Preview"];
	previewState = NO;
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
			
		[userDefaults setValue:[cityText stringValue] forKey:@"SetCity"];
		[userDefaults setValue:[stateText stringValue] forKey:@"SetState"];
		[userDefaults setValue:[countryText stringValue] forKey:@"SetCountry"];

		[currentLocation setStringValue:[[[[[userDefaults valueForKey:@"SetCity"] stringByAppendingString:@", "] stringByAppendingString:[userDefaults valueForKey:@"SetState"]] stringByAppendingString:@" "] stringByAppendingString:[userDefaults valueForKey:@"SetCountry"]]];	

		[self saveAndApply];
	}
	else
	{
		[lookupStatus setStringValue:@"Error: Unable to find location."];
		[lookupIndicator stopAnimation:sender];
	}
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[self sound_toggle:nil];
	[self manual_toggle:nil];
	[self displaynextprayer_toggle:nil];
	[self growl_toggle:nil];
	[self shuruq_toggle:nil];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[[self window] setDelegate:self];
	previewState = NO;
}


- (void)saveAndApply
{
	[userDefaults setFloat:[latitudeText floatValue] forKey:@"Latitude"];
	[userDefaults setFloat:[longitudeText floatValue] forKey:@"Longitude"];
	
	if ([toggleNextPrayer state] == NSOffState) {
		[userDefaults setBool:YES forKey:@"DisplayIcon"];
	}
	
	[userDefaults setInteger:[minutesBeforeShuruq intValue]forKey:@"MinutesBeforeShuruq"];
	
	[cityText setStringValue:[userDefaults valueForKey:@"SetCity"]];
	[stateText setStringValue:[userDefaults valueForKey:@"SetState"]];
	[countryText setStringValue:[userDefaults valueForKey:@"SetCountry"]];
	
	[userDefaults setValue:[userDefaults valueForKey:@"SetCity"] forKey:@"LocCity"];
	[userDefaults setValue:[userDefaults valueForKey:@"SetState"] forKey:@"LocState"];
	[userDefaults setValue:[userDefaults valueForKey:@"SetCountry"] forKey:@"LocCountry"];

	[[AppController sharedController] applyPrefs];

}

- (void)windowWillClose:(NSNotification *)notification
{
	[self saveAndApply];
}

- (IBAction)applyChange:(id)sender
{
	[self saveAndApply];
}

- (IBAction)changePrayerTimes:(id)sender
{
	[self saveAndApply];
}


- (IBAction)setCoordinates:(id)sender
{
	[self saveAndApply];
 	[currentLocation setStringValue:[NSString stringWithFormat:@"Manually set to (%3.4f,%3.4f)",[userDefaults floatForKey:@"Latitude"],[userDefaults floatForKey:@"Longitude"]]];
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


- (IBAction)selectAdhan:(id)sender 
{

	NSArray *adhanFileTypes = [NSArray arrayWithObjects:@"mp3", @"wav",@"m4a",nil];
	
	NSOpenPanel *attachmentPanel = [NSOpenPanel openPanel];
	[attachmentPanel beginForDirectory:nil 
								  file:nil 
								 types:adhanFileTypes
					  modelessDelegate:self
						didEndSelector:@selector(addAttachmentDidEnd:returnCode:contextInfo:)  
						   contextInfo:NULL]; 
}


@end
