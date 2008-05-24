#import "PrefController.h"

@implementation PrefController


/****************/
/* UI FUNCTIONS */
/****************/

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	fileManager = [NSFileManager defaultManager];
	
	
	[displayNextPrayerName setAutoenablesItems:NO];
	[displayNextPrayerTime setAutoenablesItems:NO];
	[self selectDisplayNextPrayerOption:self];
	
	//gray out any options that need to be grayed out
	[self locationToggle];
	[self enableSoundToggle:self];
	[self enableGrowlToggle:self];
	[self displayNextPrayerToggle:self];	
	[self shuruqReminderToggle:self];
	[self fajrReminderToggle:self];
	

	if([fileManager fileExistsAtPath:[userDefaults stringForKey:@"UserSoundFile"]]) {
		[self insertUserAdhan:[userDefaults stringForKey:@"UserSoundFile"]];
	} else {
		if([userDefaults boolForKey:@"UserSound"]) {
			[userDefaults setBool:NO forKey:@"UserSound"];
			[userDefaults setInteger:0 forKey:@"SoundFile"];
			[self saveAndApply];
		}
	}
	
	[soundFile selectItemAtIndex:[userDefaults integerForKey:@"SoundFile"]];

	
	if([self startsAtLogin]) {
		[startAtLogin setState:1];
		[userDefaults setBool:YES forKey:@"StartAtLogin"];
	} else {
		[startAtLogin setState:0];
		[userDefaults setBool:NO forKey:@"StartAtLogin"];
	}
}

- (void)setupToolbar
{
	[self addView:generalPrefsView label:@"General"];
	[self addView:locationPrefsView label:@"Location"];
	[self addView:calculationsPrefsView label:@"Prayer Times"];
	[self addView:soundPrefsView label:@"Alerts"];
	[self addView:advancedPrefsView label:@"Advanced"];
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	
	[lookupStatus setStringValue:@""];
	[lookupIndicator setDisplayedWhenStopped:NO];
	[location setStringValue:[userDefaults stringForKey:@"Location"]];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[[self window] setDelegate:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self saveAndApply];
}


/*********************/
/* GENERAL FUNCTIONS */
/*********************/

- (IBAction)displayNextPrayerToggle:(id)sender
{
    if ([displayNextPrayer state] == NSOffState)
	{
		[displayIcon setState:1];
		[userDefaults setBool:YES forKey:@"DisplayIcon"];
		[displayNextPrayerName setEnabled:NO];
		[displayNextPrayerNameTitleText setTextColor:[NSColor grayColor]];
		[displayNextPrayerTime setEnabled:NO];
		[displayNextPrayerTimeTitleText setTextColor:[NSColor grayColor]];
	} 
	else 
	{
		[displayNextPrayerName setEnabled:YES];
		[displayNextPrayerNameTitleText setTextColor:[NSColor blackColor]];
		[displayNextPrayerTime setEnabled:YES];		
		[displayNextPrayerTimeTitleText setTextColor:[NSColor blackColor]];
	}
	
	[self saveAndApply];
}

- (IBAction)displayIconToggle:(id)sender
{
    if ([displayIcon state] == NSOffState)
	{
		[displayNextPrayer setState:1];
		[userDefaults setBool:YES forKey:@"DisplayNextPrayer"];
		[self displayNextPrayerToggle:nil];
	} 

	[self saveAndApply];
}

- (IBAction)selectDisplayNextPrayerOption:(id)sender
{
	if([displayNextPrayerName indexOfSelectedItem] == 2) {
	// if name is not displayed, disable option to not display time
		[[displayNextPrayerTime itemAtIndex:2] setEnabled:NO];
		[[displayNextPrayerName itemAtIndex:2] setEnabled:YES];
		
	} else if([displayNextPrayerTime indexOfSelectedItem] == 2) {
	// if time is not displayed, disable option to not display name
		[[displayNextPrayerName itemAtIndex:2] setEnabled:NO];
		[[displayNextPrayerTime itemAtIndex:2] setEnabled:YES];	
			
	} else {
	// otherwise, enable the ability to not display either one
		[[displayNextPrayerName itemAtIndex:2] setEnabled:YES];
		[[displayNextPrayerTime itemAtIndex:2] setEnabled:YES];		
	}
	
	[self saveAndApply];
}

- (IBAction)startAtLoginToggle:(id)sender
{
	int i = 0;
	NSMutableArray* loginItems;

    loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    loginItems =  [[loginItems autorelease] mutableCopy];
	
	NSMutableDictionary *loginObject = [[NSMutableDictionary alloc] initWithCapacity:2];

	if([startAtLogin state] == NSOnState) {

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


- (BOOL)startsAtLogin
{
	BOOL starts = NO;
	int i = 0;
	NSMutableArray* loginItems;
	
    loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    loginItems =  [[loginItems autorelease] mutableCopy];
	

	for (i=0;i<[loginItems count];i++)
	{
		if ([[[loginItems objectAtIndex:i] objectForKey:@"Path"] isEqualToString:[[NSBundle mainBundle] bundlePath]]) {
			starts = YES;
		}
	}
	
    [loginItems release];
	return starts;
}


- (IBAction)checkForUpdates:(id)sender
{
	[[AppController sharedController] checkForUpdate:NO];
}


/**********************/
/* LOCATION FUNCTIONS */
/**********************/

- (IBAction)manualLocationToggle:(id)sender
{
    if ([manualLocation state] == NSOffState)
	{
		[self lookupLocation:self];
	}
	
	[self locationToggle];
}

- (void)locationToggle 
{
    if ([manualLocation state] == NSOffState)
	{
		[latitude setEnabled:NO];
		[latitudeLabel setTextColor:[NSColor grayColor]];
		[longitude setEnabled:NO];
		[longitudeLabel setTextColor:[NSColor grayColor]];
		[setManualLocation setEnabled:NO];
		[location setEnabled:YES];
		[locationTitleText setTextColor:[NSColor blackColor]];
		[setLocation setEnabled:YES];
	}
	else
	{
		[latitude setEnabled:YES];
		[latitudeLabel setTextColor:[NSColor blackColor]];
		[longitude setEnabled:YES];
		[longitudeLabel setTextColor:[NSColor blackColor]];
		[setManualLocation setEnabled:YES];
		[location setEnabled:NO];
		[locationTitleText setTextColor:[NSColor grayColor]];
		[setLocation setEnabled:NO];
		[lookupStatus setStringValue:@""];
		[lookupIndicator setDisplayedWhenStopped:NO];
	}
}

- (IBAction)lookupLocation:(id)sender 
{

	[lookupIndicator setDisplayedWhenStopped:YES];
	[lookupStatus setStringValue:@"Looking up latitude and longitude..."];
	[lookupStatus setTextColor:[NSColor blackColor]];
	[locationPrefsView display];

	[lookupIndicator startAnimation:sender];
	

	NSString *userLocation = [location stringValue];
		
	NSString *urlSafeUserLocation =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) userLocation, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://guidanceapp.com/location.php?loc=%@",urlSafeUserLocation];
	NSDictionary *coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	BOOL valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	
	if (valid)
	{
		[latitude setFloatValue: [[coordDict valueForKey:@"latitude"] doubleValue]];
		[longitude setFloatValue: [[coordDict valueForKey:@"longitude"] doubleValue]];
		

		[lookupStatus setStringValue:@"Your location has been set"];
		[lookupStatus setTextColor:[NSColor blackColor]];
		[lookupIndicator stopAnimation:sender];
		
		[userDefaults setValue:[location stringValue] forKey:@"Location"];	

		[self saveAndApply];
	}
	else
	{
		[lookupStatus setStringValue:@"Error: Unable to find location"];
		[lookupStatus setTextColor:[NSColor redColor]];
		[lookupIndicator stopAnimation:sender];
	}
}


/*************************/
/* CALCULATION FUNCTIONS */
/*************************/

- (IBAction)advancedToggle:(id)sender
{
	NSWindow *calcWindow = [calculationsPrefsView window];
	
	
	NSRect expandedWindowSize = {(NSPoint){0,0},(NSSize){375,500}};
	NSRect collapsedWindowSize = {(NSPoint){0,0},(NSSize){375,270}};
	
	NSRect expandedWindowRect = NSMakeRect([calcWindow frame].origin.x - 
		(expandedWindowSize.size.width - [calcWindow frame].size.width), [calcWindow frame].origin.y - 
        (expandedWindowSize.size.height - [calcWindow frame].size.height), expandedWindowSize.size.width, expandedWindowSize.size.height);
	
	NSRect collapsedWindowRect = NSMakeRect([calcWindow frame].origin.x - 
		(collapsedWindowSize.size.width - [calcWindow frame].size.width), [calcWindow frame].origin.y - 
        (collapsedWindowSize.size.height - [calcWindow frame].size.height), collapsedWindowSize.size.width, collapsedWindowSize.size.height);
	
    if ([expandAdvanced state] == NSOffState)
	{
		[advancedCalculationsPrefsView setHidden:YES];
		[calcWindow setFrame:collapsedWindowRect display:YES animate:YES];
	} 
	else 
	{
		[advancedCalculationsPrefsView setHidden:NO];


		[advancedCalculationsPrefsView setFrameSize:(NSSize){350,300}];
		[advancedCalculationsPrefsView setFrameOrigin:(NSPoint){10,-190}];
		
		[advancedCalculationsPrefsView display];
		[calcWindow setFrame:expandedWindowRect display:YES animate:YES];

	}
}


/*******************/
/* ALERT FUNCTIONS */
/*******************/

- (IBAction)shuruqReminderToggle:(id)sender
{
    if ([shuruqReminder state] == NSOffState)
	{
		[minutesBeforeShuruq setEnabled:NO];
	} 
	else 
	{
		[minutesBeforeShuruq setEnabled:YES];	
	}
}

- (IBAction)fajrReminderToggle:(id)sender
{
    if ([fajrReminder state] == NSOffState)
	{
		[minutesBeforeFajr setEnabled:NO];
	} 
	else 
	{
		[minutesBeforeFajr setEnabled:YES];	
	}
}

- (IBAction)enableGrowlToggle:(id)sender
{
    if ([enableGrowl state] == NSOffState)
	{
		[stickyGrowl setEnabled:NO];
	} 
	else 
	{
		[stickyGrowl setEnabled:YES];	
	}
}

- (IBAction)enableSoundToggle:(id)sender
{
    if ([enableSound state] == NSOffState)
	{
		[previewSound setEnabled:NO];
		[soundFile setEnabled:NO];
		[soundFileTitleText setTextColor:[NSColor grayColor]];
		[playFajr setEnabled:NO];
		[playFajrTitleText setTextColor:[NSColor grayColor]];
		[playDhuhur setEnabled:NO];
		[playDhuhurTitleText setTextColor:[NSColor grayColor]];
		[playAsr setEnabled:NO];
		[playAsrTitleText setTextColor:[NSColor grayColor]];
		[playMaghrib setEnabled:NO];
		[playMaghribTitleText setTextColor:[NSColor grayColor]];
		[playIsha setEnabled:NO];
		[playIshaTitleText setTextColor:[NSColor grayColor]];
		
		[shuruqReminder setEnabled:NO];
		[minutesBeforeShuruq setEnabled:NO];
		[minutesBeforeShuruqText setTextColor:[NSColor grayColor]];
		
		[fajrReminder setEnabled:NO];
		[minutesBeforeFajr setEnabled:NO];
		[minutesBeforeFajrText setTextColor:[NSColor grayColor]];
	}
	else
	{
		[previewSound setEnabled:YES];
		[soundFile setEnabled:YES];
		[soundFileTitleText setTextColor:[NSColor blackColor]];
		[playFajr setEnabled:YES];
		[playFajrTitleText setTextColor:[NSColor blackColor]];
		[playDhuhur setEnabled:YES];
		[playDhuhurTitleText setTextColor:[NSColor blackColor]];
		[playAsr setEnabled:YES];	
		[playAsrTitleText setTextColor:[NSColor blackColor]];	
		[playMaghrib setEnabled:YES];
		[playMaghribTitleText setTextColor:[NSColor blackColor]];
		[playIsha setEnabled:YES];
		[playIshaTitleText setTextColor:[NSColor blackColor]];
				
		[shuruqReminder setEnabled:YES];
			if([shuruqReminder state] == NSOnState) { 
				[minutesBeforeShuruq setEnabled:YES];
			}	
		[minutesBeforeShuruqText setTextColor:[NSColor blackColor]];
		
		
		[fajrReminder setEnabled:YES];
			if([fajrReminder state] == NSOnState) { 
				[minutesBeforeFajr setEnabled:YES];
			}
		[minutesBeforeFajrText setTextColor:[NSColor blackColor]];
	}
}

- (IBAction)playPreview:(id)sender
{
	if (!playingPreview)
	{
		// play sound
		switch ([soundFile indexOfSelectedItem])
		{
			case 1:		sound = [NSSound soundNamed:@"makkah"]; break;
			case 2:		sound = [NSSound soundNamed:@"alaqsa"]; break;
			case 3:		sound = [NSSound soundNamed:@"istanbul"]; break;
			case 5:		sound = [[NSSound alloc] initWithContentsOfFile:[userDefaults stringForKey:@"UserSoundFile"] byReference:NO]; break;
			case 0:
			default:	sound = [NSSound soundNamed:@"yusufislam"]; break;
		}
		
		[sound setDelegate:self];
		[sound play];
		
		// change button text to "Stop"
		if([sound isPlaying]) 
		{
			[previewSound setTitle:@"Stop"];
			playingPreview = !playingPreview;
		}
	}
	else
	{
		// stop sound
		[sound stop];
	}
}

- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful
{
	[previewSound setTitle:@"Preview"];
	playingPreview = NO;
}

- (IBAction)selectAdhan:(id)sender 
{

	if([[soundFile titleOfSelectedItem] isEqualToString:@"Select..."]) {
	
		NSArray *adhanFileTypes = [NSArray arrayWithObjects:@"mp3", @"wav",@"m4a",nil];
		NSOpenPanel * panel = [NSOpenPanel openPanel];
		[panel setPrompt: @"Select"];
		[panel setAllowsMultipleSelection: NO];
		[panel setCanChooseFiles: YES];
		[panel setCanChooseDirectories: NO];
		[panel setCanCreateDirectories: NO];
		[panel beginSheetForDirectory: nil 
			file: nil 
			types: adhanFileTypes
			modalForWindow: [self window] 
			modalDelegate: self 
			didEndSelector:
			@selector(selectAdhanClosed:returnCode:contextInfo:) 
			contextInfo: nil];
			
	} else if([soundFile indexOfSelectedItem] < 4) {
	
		[userDefaults setInteger:[soundFile indexOfSelectedItem] forKey:@"SoundFile"];
		[userDefaults setBool:NO forKey:@"UserSound"];
		
	} else if([soundFile indexOfSelectedItem] == 5) {
	
		[userDefaults setInteger:5 forKey:@"SoundFile"];
		[userDefaults setBool:YES forKey:@"UserSound"];

	}
	
	[self saveAndApply];
}

- (void) selectAdhanClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
	if (code == NSOKButton) {

		[userDefaults setObject:[[openPanel filenames] objectAtIndex: 0] forKey:@"UserSoundFile"];
		[self insertUserAdhan:[[openPanel filenames] objectAtIndex: 0]];

		[userDefaults setBool:YES forKey:@"UserSound"];		
		[userDefaults setInteger:5 forKey:@"SoundFile"];
		[soundFile selectItemAtIndex:5];
		
	} else {
	
		[userDefaults setBool:NO forKey:@"UserSound"];
		[soundFile selectItemAtIndex:[userDefaults integerForKey:@"SoundFile"]];
		
	}
	
	[self saveAndApply];
}

- (void) insertUserAdhan: (NSString *) userSoundFileName {
	NSString *onlyName = [[NSString alloc] initWithString:[userSoundFileName lastPathComponent]];
	if([soundFile numberOfItems] <= 6) {
		[soundFile insertItemWithTitle:onlyName atIndex:5];
		[[soundFile menu] insertItem:[NSMenuItem separatorItem] atIndex:6];
	} else {
		[soundFile removeItemAtIndex:5];
		[soundFile insertItemWithTitle:onlyName atIndex:5];
	}
}


/******************/
/* MISC FUNCTIONS */
/******************/

- (void)saveAndApply
{	
	//save latitude and longitude
	[userDefaults setFloat:[latitude floatValue] forKey:@"Latitude"];
	[userDefaults setFloat:[longitude floatValue] forKey:@"Longitude"];	

	//write user preferences to pref file
	[userDefaults synchronize];

	//tell appcontroller to check and apply prefs
	[[AppController sharedController] applyPrefs];
}

- (IBAction)applyChange:(id)sender
{
	[self saveAndApply];
}


@end