#import "PrefController.h"

@implementation PrefController


/****************/
/* UI FUNCTIONS */
/****************/

- (void)awakeFromNib
{
	// register user defaults preference plist file
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	fileManager = [NSFileManager defaultManager];
	
	timezoneArray = [[NSArray arrayWithObjects:
					   [NSNumber numberWithFloat:-12], 
					   [NSNumber numberWithFloat:-11], 
					   [NSNumber numberWithFloat:-10], 
					   [NSNumber numberWithFloat:-9], 
					   [NSNumber numberWithFloat:-8], 
					   [NSNumber numberWithFloat:-7], 
					   [NSNumber numberWithFloat:-6], 
					   [NSNumber numberWithFloat:-5], 
					   [NSNumber numberWithFloat:-4.5], 
					   [NSNumber numberWithFloat:-4], 
					   [NSNumber numberWithFloat:-3.5], 
					   [NSNumber numberWithFloat:-3], 
					   [NSNumber numberWithFloat:-2], 
					   [NSNumber numberWithFloat:-1], 
					   [NSNumber numberWithFloat:0], 
					   [NSNumber numberWithFloat:1], 
					   [NSNumber numberWithFloat:2], 
					   [NSNumber numberWithFloat:3], 
					   [NSNumber numberWithFloat:3.5], 
					   [NSNumber numberWithFloat:4], 
					   [NSNumber numberWithFloat:4.5], 
					   [NSNumber numberWithFloat:5], 
					   [NSNumber numberWithFloat:5.5], 
					   [NSNumber numberWithFloat:6], 
					   [NSNumber numberWithFloat:7], 
					   [NSNumber numberWithFloat:8], 
					   [NSNumber numberWithFloat:9], 
					   [NSNumber numberWithFloat:9.5], 
					   [NSNumber numberWithFloat:10], 
					   [NSNumber numberWithFloat:11], 
					   [NSNumber numberWithFloat:12], 
					   nil] retain];	
	
	
	
	// grey out disabled menu bar display options
	[displayNextPrayerName setAutoenablesItems:NO];
	[displayNextPrayerTime setAutoenablesItems:NO];
	[self selectDisplayNextPrayerOption:self];
	
	// gray out any options that need to be grayed out
	[self systemTimezoneToggle:self];
	[self enableSoundToggle:self];
	[self enableGrowlToggle:self];
	[self displayNextPrayerToggle:self];	
	[self shuruqReminderToggle:self];
	[self fajrReminderToggle:self];
	

	// if user selected file still exists, add that item to the adhan drop down
	if([fileManager fileExistsAtPath:[userDefaults stringForKey:@"UserSoundFile"]]) {
		[self insertUserAdhan:[userDefaults stringForKey:@"UserSoundFile"]];
	} else {
		// if file no longer exists then remove that choice from the user preferences
		if([userDefaults boolForKey:@"UserSound"]) {
			[userDefaults setBool:NO forKey:@"UserSound"];
			[userDefaults setInteger:0 forKey:@"SoundFile"];
			[self saveAndApply];
		}
	}
	
	// select the adhan choice in the adhan drop down
	[soundFile selectItemAtIndex:[userDefaults integerForKey:@"SoundFile"]];
	
	
	//if custom sunrise and sunset angles exist, insert them in the method drop down
	if([userDefaults floatForKey:@"CustomSunriseAngle"] > 0 && [userDefaults floatForKey:@"CustomSunsetAngle"] > 0) {
		[self insertCustomMethod];
	}
	
	//select the method in the method drop down
	[method selectItemAtIndex:[userDefaults integerForKey:@"Method"]];
	
	
	//select the timezone in the timezone drop down
	[timezone selectItemAtIndex:[timezoneArray indexOfObject:[NSNumber numberWithFloat:[userDefaults floatForKey:@"Timezone"]]]];

	// check if Guidance still starts at login and modify the checkbox and preference value 
	// to reflect this because user can modify this externally in the system preferences
	if([self startsAtLogin]) {
		[startAtLogin setState:1];
		[userDefaults setBool:YES forKey:@"StartAtLogin"];
	} else {
		[startAtLogin setState:0];
		[userDefaults setBool:NO forKey:@"StartAtLogin"];
	}
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	
	// hide any location lookup items and set the location text field
	// to the last successfully looked up location
	[lookupIndicator setDisplayedWhenStopped:NO];
	[lookupStatusImage setImage:nil];
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

- (void)setupToolbar
{
	[self addView:generalPrefsView label:@"General"];
	[self addView:locationPrefsView label:@"Location"];
	[self addView:calculationsPrefsView label:@"Prayer Times"];
	[self addView:soundPrefsView label:@"Alerts"];
	[self addView:advancedPrefsView label:@"Advanced"];
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
	[self saveAndApply];
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

- (IBAction)lookupLocation:(id)sender 
{
	[lookupStatusImage setImage:nil];
	[lookupIndicator startAnimation:nil];
	[NSThread detachNewThreadSelector:@selector(locationSearch) toTarget:self withObject:nil];
}

- (void)locationSearch
{
	NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
	
	NSString *userLocation = [location stringValue];
	
	NSString *urlSafeUserLocation =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) userLocation, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://guidanceapp.com/geocode-google.php?location=%@",urlSafeUserLocation];
	
	NSDictionary *coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	BOOL valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	
	[lookupIndicator stopAnimation:nil];
	
	if (valid)
	{
		[userDefaults setFloat:[[coordDict valueForKey:@"latitude"] doubleValue] forKey:@"Latitude"];
		[userDefaults setFloat:[[coordDict valueForKey:@"longitude"] doubleValue] forKey:@"Longitude"];
		[userDefaults setValue:[coordDict valueForKey:@"address"] forKey:@"Location"];	
		
		
		[location setStringValue:[coordDict valueForKey:@"address"]];
		
		[lookupStatusImage setImage:[NSImage imageNamed:@"check"]];
		
		[self saveAndApply];
	}
	else
	{
		[lookupStatusImage setImage:[NSImage imageNamed:@"error"]];
	}	
	
	
	[autoreleasePool release];
	[NSThread exit];
}

- (IBAction)systemTimezoneToggle:(id)sender
{
	if ([systemTimezone state] == NSOffState)
	{
		[daylightSavings setEnabled:YES];
		[timezone setEnabled:YES];
		
		[timezone selectItemAtIndex:[timezoneArray indexOfObject:[NSNumber numberWithFloat:[userDefaults floatForKey:@"Timezone"]]]];
	} 
	else 
	{
		if([[NSTimeZone systemTimeZone] isDaylightSavingTime]) {
			[daylightSavings setState:NSOnState];
			[userDefaults setBool:YES forKey:@"DaylightSavings"];
		} else {
			[daylightSavings setState:NSOffState];
			[userDefaults setBool:NO forKey:@"DaylightSavings"];
		}
		
		float systemTimezoneValue = [[NSTimeZone systemTimeZone] secondsFromGMT]/3600;
		if([[NSTimeZone systemTimeZone] isDaylightSavingTime]) systemTimezoneValue--;
		
		[timezone selectItemAtIndex:[timezoneArray indexOfObject:[NSNumber numberWithFloat:systemTimezoneValue]]];
		
		[daylightSavings setEnabled:NO];
		[timezone setEnabled:NO];
	}
	
	[self selectTimezone:self];
	[self saveAndApply];
}

- (IBAction)selectTimezone:(id)sender
{
	[userDefaults setFloat:[[timezoneArray objectAtIndex:[timezone indexOfSelectedItem]] floatValue] forKey:@"Timezone"];
	[self saveAndApply];
}


/*************************/
/* PRAYER TIME FUNCTIONS */
/*************************/

- (IBAction)selectMethod:(id)sender 
{
	if([[method titleOfSelectedItem] isEqualToString:@"Other..."]) {
		[NSApp beginSheet:customMethodSheet 
			modalForWindow:[self window] 
			modalDelegate:self 
			didEndSelector:@selector(customMethodClosed:) 
			contextInfo:nil];
	} else {
		[userDefaults setInteger:[method indexOfSelectedItem] forKey:@"Method"];
		[self saveAndApply];
	}
}

- (void)customMethodClosed:(NSWindow *)sheet 
{
	[sheet orderOut:self];
}

- (IBAction)cancelCustomMethod: (id)sender 
{
	[NSApp endSheet:customMethodSheet];	
	[method selectItemAtIndex:[userDefaults integerForKey:@"Method"]];
}


- (IBAction)saveCustomMethod: (id)sender 
{
	[NSApp endSheet:customMethodSheet];	

	if([sunriseAngle floatValue] > 0 && [sunsetAngle floatValue] > 0) {
		[userDefaults setFloat:[sunriseAngle floatValue] forKey:@"CustomSunriseAngle"];
		[userDefaults setFloat:[sunsetAngle floatValue] forKey:@"CustomSunsetAngle"];
		
		[self insertCustomMethod];
		
		[method selectItemAtIndex:7];
		[userDefaults setInteger:[method indexOfSelectedItem] forKey:@"Method"];
	} else {
		[method selectItemAtIndex:[userDefaults integerForKey:@"Method"]];	
	}
	
	[self saveAndApply];
}

- (void)insertCustomMethod 
{
	NSString *customMethodTitle = [NSString stringWithFormat:@"Sunrise %.1f°, Sunset %.1f°",[userDefaults floatForKey:@"CustomSunriseAngle"],[userDefaults floatForKey:@"CustomSunsetAngle"]];
	
	if([method numberOfItems] <= 8) {
		[[method menu] insertItem:[NSMenuItem separatorItem] atIndex:6];
		[method insertItemWithTitle:customMethodTitle atIndex:7];
	} else {
		[method removeItemAtIndex:7];
		[method insertItemWithTitle:customMethodTitle atIndex:7];
	}	
}


- (IBAction)getMethodHelp: (id)sender
{
	NSString *bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"method"  inBook:bookName];
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
	
	[self saveAndApply];
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
	
	[self saveAndApply];
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
	
	[self saveAndApply];
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
	
	[self saveAndApply];
}

- (IBAction)playPreview:(id)sender
{
	if(![[AppController sharedController] isAdhanPlaying])
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
		NSOpenPanel *panel = [NSOpenPanel openPanel];
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