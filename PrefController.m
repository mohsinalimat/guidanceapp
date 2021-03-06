//
//  PrefController.m
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

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
	
	
	playingStatus = [NSMutableArray arrayWithObjects:	
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
						[NSNumber numberWithBool:NO],
					nil];
	
	[playingStatus retain];
	
	// retain these objects and set them to
	// whatever the selected prayer is
	[adhanOption retain];
	[adhanPreview retain];
	[prayerAdhanKey retain];
	[customAdhanKey retain];
	[customAdhanFileKey retain];
	
	[tempSelection retain];
	
	// grey out disabled menu bar display options
	[displayNextPrayerName setAutoenablesItems:NO];
	[displayNextPrayerTime setAutoenablesItems:NO];
	[self selectDisplayNextPrayerOption:self];
	
	// gray out any options that need to be grayed out
	[self systemTimezoneToggle:self];
	[self enableGrowlToggle:self];
	[self displayNextPrayerToggle:self];
	[self shuruqReminderToggle:self];
	[self fajrReminderToggle:self];
	[self enableSilentModeToggle:self];
	
	//re-insert any custom adhans the user had selected
	[self restoreCustomAdhans];
	
	//if custom sunrise and sunset angles exist, insert them in the method drop down
	if([userDefaults floatForKey:@"CustomSunriseAngle"] > 0 && [userDefaults floatForKey:@"CustomSunsetAngle"] > 0) {
		[self insertCustomMethod];
	}
	
	//select the method in the method drop down
	[method selectItemAtIndex:[userDefaults integerForKey:@"Method"]];
	
	
	//select the timezone in the timezone drop down
	[timezone selectItemAtIndex:[timezoneArray indexOfObject:[NSNumber numberWithFloat:[userDefaults floatForKey:@"Timezone"]]]];

	// select volume
	[volumeSlider setFloatValue:[userDefaults floatForKey:@"AdhanVolume"]];
	
	//create sound object
	sound = [[QTMovie alloc] init];
	
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
	
	
	[NSTimeZone resetSystemTimeZone];
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
	[loginObject release];

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
	NSDictionary *coordDict;
	BOOL manualCoordinates = NO;
	BOOL valid = NO;
	
	//check for manual coordinates
	NSArray *coordArray = [userLocation componentsSeparatedByString:@","];
	if([coordArray count] == 2) {
		if([[coordArray objectAtIndex:0] doubleValue] != 0.0 && [[coordArray objectAtIndex:0] doubleValue] != 0.0) {
			manualCoordinates = YES;
			if(fabs([[coordArray objectAtIndex:0] doubleValue]) <= 90 && fabs([[coordArray objectAtIndex:0] doubleValue]) <= 180) {
				valid = YES;
				coordDict = [NSDictionary dictionaryWithObjects:
											[NSArray arrayWithObjects:[NSNumber numberWithDouble:[[coordArray objectAtIndex:0] doubleValue]], [NSNumber numberWithDouble:[[coordArray objectAtIndex:1] doubleValue]], userLocation, nil] 
													forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", @"address", nil]];
			}
		}
	}
	
	if(!manualCoordinates) {
		NSString *urlSafeUserLocation =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) userLocation, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
		NSString *urlString = [NSString stringWithFormat:@"http://batoulapps.net/services/guidance/geocode-google.php?location=%@",urlSafeUserLocation];
	
		coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
		valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	}
	
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

- (IBAction)shuruqReminderToggle:(id)sender
{
    if ([shuruqReminder state] == NSOffState)
	{
		[minutesBeforeShuruq setEnabled:NO];
		[shuruqReminderAdhanOption setEnabled:NO];
		[shuruqReminderAdhanPreview setEnabled:NO];
	} 
	else 
	{
		[minutesBeforeShuruq setEnabled:YES];
		[shuruqReminderAdhanOption setEnabled:YES];
		[shuruqReminderAdhanPreview setEnabled:YES];
	}
	
	[self saveAndApply];
}

- (IBAction)fajrReminderToggle:(id)sender
{
    if ([fajrReminder state] == NSOffState)
	{
		[minutesBeforeFajr setEnabled:NO];
		[fajrReminderAdhanOption setEnabled:NO];
		[fajrReminderAdhanPreview setEnabled:NO];
	} 
	else 
	{
		[minutesBeforeFajr setEnabled:YES];	
		[fajrReminderAdhanOption setEnabled:YES];
		[fajrReminderAdhanPreview setEnabled:YES];
	}
	
	[self saveAndApply];
}

- (IBAction)enableSilentModeToggle:(id)sender
{
	if ([enableSilent state] == NSOnState)
	{
		[fajrAdhanOption setEnabled:NO];
		[fajrAdhanPreview setEnabled:NO];
		[dhuhurAdhanOption setEnabled:NO];
		[dhuhurAdhanPreview setEnabled:NO];
		[asrAdhanOption setEnabled:NO];
		[asrAdhanPreview setEnabled:NO];
		[maghribAdhanOption setEnabled:NO];
		[maghribAdhanPreview setEnabled:NO];
		[ishaAdhanOption setEnabled:NO];
		[ishaAdhanPreview setEnabled:NO];
		[volumeSlider setEnabled:NO];
		
		[fajrAdhanTitleText setTextColor:[NSColor grayColor]];
		[dhuhurAdhanTitleText setTextColor:[NSColor grayColor]];
		[asrAdhanTitleText setTextColor:[NSColor grayColor]];
		[maghribAdhanTitleText setTextColor:[NSColor grayColor]];
		[ishaAdhanTitleText setTextColor:[NSColor grayColor]];
		[volumeText setTextColor:[NSColor grayColor]];
		
		[shuruqReminder setEnabled:NO];
		[minutesBeforeShuruq setEnabled:NO];
		[minutesBeforeShuruqText setTextColor:[NSColor grayColor]];
		[shuruqReminderAdhanOption setEnabled:NO];
		[shuruqReminderAdhanPreview setEnabled:NO];
		
		[fajrReminder setEnabled:NO];
		[minutesBeforeFajr setEnabled:NO];
		[minutesBeforeFajrText setTextColor:[NSColor grayColor]];
		[fajrReminderAdhanOption setEnabled:NO];
		[fajrReminderAdhanPreview setEnabled:NO];		
		
		[pauseItunes setEnabled:NO];
		[playDua setEnabled:NO];
	}
	else
	{
		[fajrAdhanOption setEnabled:YES];
		[fajrAdhanPreview setEnabled:YES];
		[dhuhurAdhanOption setEnabled:YES];
		[dhuhurAdhanPreview setEnabled:YES];
		[asrAdhanOption setEnabled:YES];
		[asrAdhanPreview setEnabled:YES];
		[maghribAdhanOption setEnabled:YES];
		[maghribAdhanPreview setEnabled:YES];
		[ishaAdhanOption setEnabled:YES];
		[ishaAdhanPreview setEnabled:YES];		
		[volumeSlider setEnabled:YES];
		
		[fajrAdhanTitleText setTextColor:[NSColor blackColor]];
		[dhuhurAdhanTitleText setTextColor:[NSColor blackColor]];
		[asrAdhanTitleText setTextColor:[NSColor blackColor]];	
		[maghribAdhanTitleText setTextColor:[NSColor blackColor]];
		[ishaAdhanTitleText setTextColor:[NSColor blackColor]];
		[volumeText setTextColor:[NSColor blackColor]];
		
		[shuruqReminder setEnabled:YES];
		if([shuruqReminder state] == NSOnState) {
			[minutesBeforeShuruq setEnabled:YES];
			[shuruqReminderAdhanOption setEnabled:YES];
			[shuruqReminderAdhanPreview setEnabled:YES];
		}	
		[minutesBeforeShuruqText setTextColor:[NSColor blackColor]];
		
		[fajrReminder setEnabled:YES];
		if([fajrReminder state] == NSOnState) { 
			[minutesBeforeFajr setEnabled:YES];
			[fajrReminderAdhanOption setEnabled:YES];
			[fajrReminderAdhanPreview setEnabled:YES];
		}
		[minutesBeforeFajrText setTextColor:[NSColor blackColor]];
		
		[pauseItunes setEnabled:YES];
		[playDua setEnabled:YES];
	}
	
	[self saveAndApply];
}

- (void) setAlertGlobals:(int)prayer 
{
	switch (prayer) {
		case 1:
			adhanOption = fajrAdhanOption;
			adhanPreview = fajrAdhanPreview;
			prayerAdhanKey = @"FajrAdhanOption";
			customAdhanKey = @"FajrAdhanUserSound";
			customAdhanFileKey = @"FajrAdhanUserSoundFile";
			break;
		case 2:
			adhanOption = dhuhurAdhanOption;
			adhanPreview = dhuhurAdhanPreview;
			prayerAdhanKey = @"DhuhurAdhanOption";
			customAdhanKey = @"DhuhurAdhanUserSound";
			customAdhanFileKey = @"DhuhurAdhanUserSoundFile";
			break;
		case 3:
			adhanOption = asrAdhanOption;
			adhanPreview = asrAdhanPreview;
			prayerAdhanKey = @"AsrAdhanOption";
			customAdhanKey = @"AsrAdhanUserSound";
			customAdhanFileKey = @"AsrAdhanUserSoundFile";
			break;
		case 4:
			adhanOption = maghribAdhanOption;
			adhanPreview = maghribAdhanPreview;
			prayerAdhanKey = @"MaghribAdhanOption";
			customAdhanKey = @"MaghribAdhanUserSound";
			customAdhanFileKey = @"MaghribAdhanUserSoundFile";
			break;
		case 5:
			adhanOption = ishaAdhanOption;
			adhanPreview = ishaAdhanPreview;
			prayerAdhanKey = @"IshaAdhanOption";
			customAdhanKey = @"IshaAdhanUserSound";
			customAdhanFileKey = @"IshaAdhanUserSoundFile";
			break;
		case 6:
			adhanOption = shuruqReminderAdhanOption;
			adhanPreview = shuruqReminderAdhanPreview;
			prayerAdhanKey = @"ShuruqReminderAdhanOption";
			customAdhanKey = @"ShuruqReminderAdhanUserSound";
			customAdhanFileKey = @"ShuruqReminderAdhanUserSoundFile";
			break;
		case 7:
			adhanOption = fajrReminderAdhanOption;
			adhanPreview = fajrReminderAdhanPreview;
			prayerAdhanKey = @"FajrReminderAdhanOption";
			customAdhanKey = @"FajrReminderAdhanUserSound";
			customAdhanFileKey = @"FajrReminderAdhanUserSoundFile";
			break;
		default:
			break;
	}
}

- (IBAction)previewFajr:(id)sender
{
	[self setAlertGlobals:1];
	[self playPreview:1];
}

- (IBAction)previewDhuhur:(id)sender
{
	[self setAlertGlobals:2];
	[self playPreview:2];	
}

- (IBAction)previewAsr:(id)sender
{
	[self setAlertGlobals:3];
	[self playPreview:3];	
}

- (IBAction)previewMaghrib:(id)sender
{
	[self setAlertGlobals:4];
	[self playPreview:4];	
}

- (IBAction)previewIsha:(id)sender
{
	[self setAlertGlobals:5];
	[self playPreview:5];	
}

- (IBAction)previewShuruqReminder:(id)sender
{
	[self setAlertGlobals:6];
	[self playPreview:6];	
}

- (IBAction)previewFajrReminder:(id)sender
{
	[self setAlertGlobals:7];
	[self playPreview:7];	
}

- (void) playPreview:(int)prayer
{
	if(![[AppController sharedController] isAdhanPlaying])
	{
		if (!playingPreview) {
			
			[playingStatus replaceObjectAtIndex:prayer-1 withObject:[NSNumber numberWithBool:YES]];

			NSString *path;
			switch ([adhanOption indexOfSelectedItem])
			{
				case 0:
					return;
				case 1:
					return;
				case 2:	
					path = [[NSBundle mainBundle] pathForResource:@"yusufislam" ofType:@"mp3"];
					break;
				case 3:		
					path = [[NSBundle mainBundle] pathForResource:@"makkah" ofType:@"mp3"];
					break;
				case 4:
					path = [[NSBundle mainBundle] pathForResource:@"alaqsa" ofType:@"mp3"];
					break;
				case 5:
					path = [[NSBundle mainBundle] pathForResource:@"istanbul" ofType:@"mp3"];
					break;
				case 6:
					path = [[NSBundle mainBundle] pathForResource:@"fajr" ofType:@"mp3"];
					break;
				case 7:
					return;
				case 8:
					if([fileManager fileExistsAtPath:[userDefaults stringForKey:customAdhanFileKey]]) {
						path = [userDefaults stringForKey:customAdhanFileKey];
					} else {
						// remove custom file option and 
						// go back to default adhan
						[adhanOption removeItemAtIndex:8];
						[adhanOption removeItemAtIndex:7];
						[adhanOption selectItemAtIndex:2];
						[userDefaults setInteger:2 forKey:prayerAdhanKey];
						[userDefaults setBool:NO forKey:customAdhanKey];
						[self saveAndApply];
						return;
					}
					break;
				default:
					return;
			}
			
			[sound release];
			sound = [[QTMovie movieWithURL:[NSURL fileURLWithPath:path] error:nil] retain];
			[sound setDelegate:self];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundDidEnd:) name:QTMovieDidEndNotification object:nil];
			
			
			if([userDefaults boolForKey:@"PauseItunes"]) {
				[[AppController sharedController] pauseItunes];	
			}
			
			[adhanPreview setImage:[NSImage imageNamed:@"Stop"]];
			[adhanPreview setAlternateImage:[NSImage imageNamed:@"StopAlt"]];
			
			playingPreview = YES;

			[sound setVolume:[volumeSlider floatValue]];
			[sound play];
			
		} else if(playingPreview && [[playingStatus objectAtIndex:prayer-1] boolValue]) {
			[sound stop];
			[self soundDidEnd:nil];
			
		}
	}
}


- (void) soundDidEnd:(id)notification
{
	[self resetPreviewButtons];
}


- (void)volumeChanged:(id)sender {
	float v = [volumeSlider floatValue];
	[userDefaults setFloat:v forKey:@"AdhanVolume"];
	if (playingPreview && sound)
		[sound setVolume:v];
	[self saveAndApply];
}


- (void) resetPreviewButtons 
{
	playingPreview = NO;
	
	//reset all objects in status array
	[playingStatus replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:5 withObject:[NSNumber numberWithBool:NO]];
	[playingStatus replaceObjectAtIndex:6 withObject:[NSNumber numberWithBool:NO]];
	
	//reset all buttons to the play symbol
	[fajrAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[fajrAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[dhuhurAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[dhuhurAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[asrAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[asrAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[maghribAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[maghribAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[ishaAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[ishaAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[shuruqReminderAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[shuruqReminderAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];
	[fajrReminderAdhanPreview setImage:[NSImage imageNamed:@"Play"]];
	[fajrReminderAdhanPreview setAlternateImage:[NSImage imageNamed:@"PlayAlt"]];	
}

- (IBAction)selectFajrAdhan:(id)sender {
	[self setAlertGlobals:1];
	[self selectCustomAdhan];
}

- (IBAction)selectDhuhurAdhan:(id)sender {
	[self setAlertGlobals:2];
	[self selectCustomAdhan];
}

- (IBAction)selectAsrAdhan:(id)sender {
	[self setAlertGlobals:3];
	[self selectCustomAdhan];
}

- (IBAction)selectMaghribAdhan:(id)sender {
	[self setAlertGlobals:4];
	[self selectCustomAdhan];
}

- (IBAction)selectIshaAdhan:(id)sender {
	[self setAlertGlobals:5];
	[self selectCustomAdhan];
}

- (IBAction)selectShuruqReminderAdhan:(id)sender {
	[self setAlertGlobals:6];
	[self selectCustomAdhan];
}

- (IBAction)selectFajrReminderAdhan:(id)sender {
	[self setAlertGlobals:7];
	[self selectCustomAdhan];
}

- (void)selectCustomAdhan 
{
	if([[adhanOption titleOfSelectedItem] isEqualToString:@"Select..."]) {
		
		//open a 'open file' dialog for them to select an audio file
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

	} else if([adhanOption indexOfSelectedItem] <= 6) {

		[userDefaults setInteger:[adhanOption indexOfSelectedItem] forKey:prayerAdhanKey];
		[userDefaults setBool:NO forKey:customAdhanKey];
		[self saveAndApply];

	} else if([adhanOption indexOfSelectedItem] == 8) {

		[userDefaults setInteger:[adhanOption indexOfSelectedItem] forKey:prayerAdhanKey];
		[userDefaults setBool:YES forKey:customAdhanKey];
		[self saveAndApply];
	}
}

- (void) selectAdhanClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
	if (code == NSOKButton) {

		[userDefaults setObject:[[openPanel filenames] objectAtIndex: 0] forKey:customAdhanFileKey];
		[self insertCustomAdhan:[[openPanel filenames] objectAtIndex: 0] toAdhanOption:adhanOption];

		[userDefaults setBool:YES forKey:customAdhanKey];		
		[userDefaults setInteger:8 forKey:prayerAdhanKey];
		
		[adhanOption selectItemAtIndex:8];
		
	} else {
		if([userDefaults integerForKey:prayerAdhanKey] != 8) {
			[userDefaults setBool:NO forKey:customAdhanKey];
		}
		
		[adhanOption selectItemAtIndex:[userDefaults integerForKey:prayerAdhanKey]];
	}
	
	[self saveAndApply];
}


- (void) insertCustomAdhan: (NSString *)fileName toAdhanOption: (NSPopUpButton *) adhanButton
{
	NSString *onlyName = [[NSString alloc] initWithString:[fileName lastPathComponent]];
	if([adhanButton numberOfItems] <= 9) {
		[adhanButton insertItemWithTitle:onlyName atIndex:8];
		[[adhanButton menu] insertItem:[NSMenuItem separatorItem] atIndex:9];
	} else {
		[adhanButton removeItemAtIndex:8];
		[adhanButton insertItemWithTitle:onlyName atIndex:8];
	}
	[onlyName release];
}

- (void) restoreCustomAdhans
{
	int i;
	for(i = 1; i <= 7; i++) {
		[self setAlertGlobals:i];
		if([fileManager fileExistsAtPath:[userDefaults stringForKey:customAdhanFileKey]]) {
			[self insertCustomAdhan:[userDefaults stringForKey:customAdhanFileKey] toAdhanOption:adhanOption];
		} else {
			// if file no longer exists then remove that choice from the user preferences
			if([userDefaults boolForKey:customAdhanKey]) {
				[userDefaults setBool:NO forKey:customAdhanKey];
				[userDefaults setInteger:2 forKey:prayerAdhanKey];
			}
		}
	}
		
	[self saveAndApply];
		
	// select the adhan choice in the adhan drop down for each one
	[fajrAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"FajrAdhanOption"]];
	[dhuhurAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"DhuhurAdhanOption"]];
	[asrAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"AsrAdhanOption"]];
	[maghribAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"MaghribAdhanOption"]];
	[ishaAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"IshaAdhanOption"]];
	[shuruqReminderAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"ShuruqReminderAdhanOption"]];
	[fajrReminderAdhanOption selectItemAtIndex:[userDefaults integerForKey:@"FajrReminderAdhanOption"]];	
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