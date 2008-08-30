//
//  AppController.m
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "AppController.h"

static AppController *sharedAppController = nil;

@implementation AppController

- (void)awakeFromNib
{	
	//create user defaults object
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	
	[userDefaults registerDefaults:appDefaults];

	adhanOptions = [NSArray arrayWithObjects:@"yusufislam", @"makkah", @"alaqsa", @"istanbul", nil];
	[adhanOptions retain];
	
	prayerTimeDate = [[NSCalendarDate calendarDate] retain]; //set date with which to check prayer times
	
	lastCheckTime = [[NSCalendarDate calendarDate] retain]; //initialize last check time
	
	todaysPrayerTimes = [[PrayerTimes alloc] init]; //initialize prayer times object 
	
	currentlyPlayingAdhan = @"";
	
	[self initPrayers]; //initialize each prayer object

	[self loadDefaults]; //load default preferences

	[self setPrayerTimes]; //sets each prayer object's prayer time
	
	[self initAppMenu]; //create menu bar
	
	[self setMenuTimes]; //initialize prayer time items in menu bar	

	nextPrayer = fajrPrayer; //initially set next prayer to fajr

	[self checkPrayerTimes]; //initial prayer time check
	
	//running loop that checks prayer times every second
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runLoop) userInfo:nil repeats:YES]; 
	
	//check if growl is installed
	if(![self isGrowlInstalled]) {
		[self doGrowl : @"Guidance" : @"Request Growl installation" : NO : nil : nil];
	}
	
	[self checkForUpdate:YES]; //check for new version	

	if(firstRun || preferencesVersion < [self getBuildNumber]) {
		[[WelcomeController sharedWelcomeWindowController] showWindow:nil];
		[[[WelcomeController sharedWelcomeWindowController] window] makeKeyAndOrderFront:nil];
		[NSApp activateIgnoringOtherApps:YES];
		
		//now that app has been run, set FirstRun to false and set the proper preferences version
		[userDefaults setBool:NO forKey:@"FirstRun"];
		
		[userDefaults setInteger:[self getBuildNumber] forKey:@"PreferencesVersion"];
	}
}


/*
 * Create prayer objects, set names, and create prayersArray
 */
- (void) initPrayers
{
	//init Prayer objects
	fajrPrayerReminder = [[Prayer alloc] init];
	fajrPrayer = [[Prayer alloc] init];
	shuruqPrayerReminder = [[Prayer alloc] init];
	shuruqPrayer = [[Prayer alloc] init];
	dhuhurPrayer = [[Prayer alloc] init];
	asrPrayer = [[Prayer alloc] init];
	maghribPrayer = [[Prayer alloc] init];
	ishaPrayer = [[Prayer alloc] init];
	tomorrowFajrPrayer = [[Prayer alloc] init];
	
	//init prayers array to loop through when checking prayer times
	prayersArray = [[NSDictionary dictionaryWithObjectsAndKeys:
				fajrPrayer,				@"0", 	 
				shuruqPrayer,			@"1", 
				dhuhurPrayer,			@"2",
				asrPrayer,				@"3",
				maghribPrayer,			@"4",
				ishaPrayer,				@"5",
				nil] retain];
	
	//set prayer object names names
	[fajrPrayerReminder setName:@"Tahajud Reminder"];
	[fajrPrayer setName: @"Fajr"];
	[shuruqPrayerReminder setName:@"Shuruq Reminder"];
	[shuruqPrayer setName: @"Shuruq"];
	[dhuhurPrayer setName: @"Dhuhur"];
	[asrPrayer setName: @"Asr"];
	[maghribPrayer setName: @"Maghrib"];
	[ishaPrayer setName: @"Isha"];
	[tomorrowFajrPrayer setName: @"Fajr"];
	
	//set prayer notification status to false
	[fajrPrayerReminder setNotified:NO];
	[fajrPrayer setNotified:NO];
	[shuruqPrayerReminder setNotified:NO];
	[shuruqPrayer setNotified:NO];
	[dhuhurPrayer setNotified:NO];
	[asrPrayer setNotified:NO];
	[maghribPrayer setNotified:NO];
	[ishaPrayer setNotified:NO];
	[tomorrowFajrPrayer setNotified:NO];
}


/*
 * Calculate and set prayer times for current date
 */
- (void) setPrayerTimes
{
	//calculate prayer times for current date
	[todaysPrayerTimes calcTimes:[NSCalendarDate calendarDate]];
		
	//set times
	[fajrPrayerReminder setTime:[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:0 hours:0 minutes:(-1*minutesBeforeTahajud) seconds:0]];
	[fajrPrayer setTime: [todaysPrayerTimes getFajrTime]];
	[shuruqPrayerReminder setTime:[[todaysPrayerTimes getShuruqTime] dateByAddingYears:0 months:0 days:0 hours:0 minutes:(-1*minutesBeforeShuruq) seconds:0]];
	[shuruqPrayer setTime: [todaysPrayerTimes getShuruqTime]];
	[dhuhurPrayer setTime: [todaysPrayerTimes getDhuhurTime]];
	[asrPrayer setTime: [todaysPrayerTimes getAsrTime]];
	[maghribPrayer setTime: [todaysPrayerTimes getMaghribTime]];
	[ishaPrayer setTime: [todaysPrayerTimes getIshaTime]];
}


/*
 * Create menu bar, icon, prayer items, and mute adhan item
 */
- (void) initAppMenu
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu];
	
	if(displayIcon) {
		[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
		[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
	}
		
	menuItems = [[NSDictionary dictionaryWithObjectsAndKeys:
                   fajrItem,	@"Fajr", 
                   shuruqItem,	@"Shuruq", 
                   dhuhurItem,	@"Dhuhur",
				   asrItem,		@"Asr",
				   maghribItem,	@"Maghrib",
				   ishaItem,	@"Isha",
                   nil] retain];
				   
	[appMenu setAutoenablesItems:NO];
	
	muteAdhan = [[NSMenuItem alloc] initWithTitle:@"Mute Adhan" action:@selector(stopAdhan:) keyEquivalent:@""];
	[muteAdhan retain];
}


/*
 * Set prayer times in menu bar
 */
- (void) setMenuTimes
{
	[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t " stringByAppendingString:[fajrPrayer getFormattedTime]],@"")];
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")];
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")];
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")];
}


/*
 * check prayer time if seconds is 0 or if its been more than 60 seconds since the last check
 */
- (void) runLoop
{	
	if([[NSCalendarDate calendarDate] secondOfMinute] == 0)
	{
		[self checkPrayerTimes];
	} else {
		int seconds = 0;
		[[NSCalendarDate calendarDate] years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:lastCheckTime];
		
		if(seconds > 60 || seconds < 0) {
			[self checkPrayerTimes];
		}
	}
}


/* 
 * recalculate and display prayer times for new day, reset prayer's notification status and check for updates
 */
- (void) updateForNewDay
{
	[self setPrayerTimes];
	[self setMenuTimes];
	
	//reset current day
	[prayerTimeDate release];
	prayerTimeDate = [[NSCalendarDate calendarDate] retain];
	
	//reset prayer notification status
	[fajrPrayerReminder setNotified:NO];
	[fajrPrayer setNotified:NO];
	[shuruqPrayerReminder setNotified:NO];
	[shuruqPrayer setNotified:NO];
	[dhuhurPrayer setNotified:NO];
	[asrPrayer setNotified:NO];
	[maghribPrayer setNotified:NO];
	[ishaPrayer setNotified:NO];
	
	//and if set, check for updates
	if(checkForUpdates) {
		[self checkForUpdate:YES];
	}	
}


/*
 * go through all the prayers and check if it is currently time to pray
 */
- (void) checkPrayerTimes
{
	//update last time prayer times were checked
	[lastCheckTime release];
	lastCheckTime = [[NSCalendarDate calendarDate] retain];
	
	//if new day, update prayer times first
	if([[NSCalendarDate calendarDate] dayOfCommonEra] != [prayerTimeDate dayOfCommonEra]) {
		[self updateForNewDay];
	}
	
	
	BOOL nextPrayerSet = NO;
	BOOL currentlyPrayerTime = NO;
	
	
	Prayer *prayer;
	NSString *name, *time;
	BOOL notified;
	int i, secondsTill, minutesTill, minuteSecondsTill;
	
	//loop through array of prayers
	for (i = 0; i < 6; i++)
	{
		prayer = [prayersArray objectForKey:[NSString stringWithFormat:@"%d",i]];

		//calculate seconds till
		[[prayer getTime] years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&secondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		//calculate minutes till
		[[prayer getTime] years:NULL months:NULL days:NULL  hours:NULL minutes:&minutesTill seconds:&minuteSecondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		if(minuteSecondsTill > 0) minutesTill++; //round minute up
		
		
		//Get next prayer
		if(secondsTill > 0 && nextPrayerSet == NO)
		{
			nextPrayer = prayer;
			nextPrayerSet = YES;
		}
		
		//check if its currently prayer time
		if ((secondsTill >= -59 && secondsTill <= 0) && ![[prayer getName] isEqualTo:@"Shuruq"])
		{
			currentlyPrayerTime = YES;
			currentPrayer = prayer;
			
			name = [prayer getName];
			time = [prayer getFormattedTime];
			notified = [prayer getNotified];
			
			//if user hasnt been notified yet
			if(!notified) 
			{
				if(displayGrowl) 
				{
					[self doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : stickyGrowl : @"" : name];
					[prayer setNotified:YES];
				}
				
				//play audio
				if([prayer getPlayAudio])
				{	
					[prayer setNotified:YES];
					
					if(![self isAdhanPlaying]) {
						[self playAdhan];
					}
					
					currentlyPlayingAdhan = name;
					[[menuItems objectForKey:name] setAction:@selector(stopAdhan:)];	
						
				}
			}
		} // end if currently prayer time
	} // end prayers array loop
	
	
	/*
	 else if(shuruqReminder && (minutesBeforeShuruq == minutesTill) && ([[prayer getName] isEqualTo:@"Shuruq"])  && !(secondsSinceNotification < 60 && secondsSinceNotification > 0))
	 {
	 currentPrayer = prayer;
	 
	 if(![self isAdhanPlaying]) {
	 [self playAdhan];
	 }
	 
	 currentlyPlayingAdhan = @"Shuruq";
	 [[menuItems objectForKey:@"Shuruq"] setAction:@selector(stopAdhan:)];
	 
	 if(displayGrowl) [self doGrowl : @"Shuruq" : [[[shuruqPrayer getFormattedTime] stringByAppendingString:[NSString stringWithFormat:@"\n%d",minutesBeforeShuruq]] stringByAppendingString:@" minutes left to pray Fajr"] : stickyGrowl : @"" : @"Shuruq"];
	 
	 [prayer setNotified:YES];
	 }
	 else if(tahajudReminder && (minutesBeforeTahajud == minutesTill) && ([[prayer getName] isEqualTo:@"Fajr"])  && !(secondsSinceNotification < 60 && secondsSinceNotification > 0))
	 {
	 currentPrayer = prayer;
	 
	 if(![self isAdhanPlaying]) {
	 [self playAdhan];
	 }
	 
	 currentlyPlayingAdhan = @"Fajr";
	 [[menuItems objectForKey:@"Fajr"] setAction:@selector(stopAdhan:)];
	 
	 if(displayGrowl) [self doGrowl : @"Tahajud" : [[NSString stringWithFormat:@"%d",minutesBeforeTahajud] stringByAppendingString:@" minutes left until Fajr"] : stickyGrowl : @"" : @"Tahajud"];
	 
	 [prayer setNotified:YES];
	 }
	 */
	
	
	
	if(nextPrayerSet == NO) {
		//calculate the time for tomorrow's fajr prayer
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
		[tomorrowFajrPrayer setTime:[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
	
		nextPrayer = tomorrowFajrPrayer;
	}
	
	[self setMenuBar : currentlyPrayerTime];
	[self setStatusIcons];
}


/*
 * icon display settings, prayer name and time display settings for menu bar
 */
- (void) setMenuBar: (BOOL) currentlyPrayerTime
{
	/* Set menu bar display */
	NSString *menuBarTitle;
	NSString *nextPrayerNameDisplay;
	NSString *nextPrayerTimeDisplay;
	
	if(displayIcon) {
		[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
		[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
	} else {
		[menuBar setImage: nil];
		[menuBar setAlternateImage: nil];
	}	
	
	
	if(displayNextPrayer) {
		if(menuDisplayName == 0) {	
			//display whole name
			nextPrayerNameDisplay = [nextPrayer getName]; 
		} else if(menuDisplayName == 1) {
			//display abbreviation
			nextPrayerNameDisplay = [[nextPrayer getName] substringToIndex:1]; 
		} else if(menuDisplayName == 2) {
			//display none
			nextPrayerNameDisplay = @"";
		}
		
		
		if(menuDisplayTime == 0) {
			//display next prayer time
			nextPrayerTimeDisplay = [[nextPrayer getTime] descriptionWithCalendarFormat: @" %1I:%M"]; 
		} else if(menuDisplayTime == 1) {
			//display amount of time left until the next prayer
			int hourCount,minuteCount,secondsCount;
			
			//calculate time until next prayer
			[[nextPrayer getTime] 
			 years:NULL months:NULL days:NULL  hours:&hourCount minutes:&minuteCount seconds:&secondsCount 
			 sinceDate:[NSCalendarDate calendarDate]];
			
			//round the seconds up
			if(secondsCount > 0) {
				if(minuteCount == 59) {
					hourCount++;
					minuteCount = 0;
				} else {
					minuteCount++;
				}
			}
			
			nextPrayerTimeDisplay = [NSString stringWithFormat:@" -%d:%02d",hourCount,minuteCount];
			
		} else if(menuDisplayTime == 2) {
			nextPrayerTimeDisplay = @"";
		}
		
		menuBarTitle = [nextPrayerNameDisplay stringByAppendingString:nextPrayerTimeDisplay];
		
	} else {
		menuBarTitle = @"";
	}
	
	//if it's time to pray, change the menu bar title to "prayer name" time for that minute
	if(currentlyPrayerTime) {
		menuBarTitle = [[currentPrayer getName] stringByAppendingString:@" time"];
	}
	
	[menuBar setTitle:NSLocalizedString(menuBarTitle,@"")]; //set menu bar title
}


/*
 * set grey icon, green icon or sound icon next to prayer names in menu bar
 */
- (void) setStatusIcons
{
	
	BOOL nextPrayerSet = NO;
	
	NSCalendarDate *prayerTime;
	NSString *prayerName, *stillTimeToPray;
	
	int i, secondsTill;
	
	for (i = 0; i < 6; i++)
	{
		prayerName = [[prayersArray objectForKey:[NSString stringWithFormat:@"%d",i]] getName];
		prayerTime = [[prayersArray objectForKey:[NSString stringWithFormat:@"%d",i]] getTime];
		
		[prayerTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&secondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		[[menuItems objectForKey:prayerName] setImage: [NSImage imageNamed: @"status_notTime"]];
		
		//Get next prayer
		if(secondsTill > 0 && nextPrayerSet == NO)
		{
			nextPrayerSet = YES;
			
			if(i == 0) {
				stillTimeToPray = @"Isha";
			} else if(i == 1) {
				stillTimeToPray = @"Fajr";
			} else if(i == 2) {
				stillTimeToPray = @"";
			} else {
				stillTimeToPray = [[prayersArray objectForKey:[NSString stringWithFormat:@"%d",i-1]] getName];
			}
			
		}
		
	}
	
	if(!nextPrayerSet) {
		stillTimeToPray = @"Isha";
	}
	
	[[menuItems objectForKey:stillTimeToPray] setImage: [NSImage imageNamed: @"status_prayerTime"]];
	[[menuItems objectForKey:currentlyPlayingAdhan] setImage: [NSImage imageNamed: @"status_sound"]];
}


- (IBAction)doNothing:(id)sender 
{
	//absolutely nothing
}


- (IBAction)stopAdhan:(id)sender 
{
	[adhan stop];
}


/*
 * set NSSound object adhan to the proper sound file and play 
 */
- (void) playAdhan
{
	if(userPrefsUserSound) {
		adhan = [[NSSound alloc] initWithContentsOfFile:userPrefsUserSoundFile byReference:YES];
	} else {
		adhan = [NSSound soundNamed:[adhanOptions objectAtIndex:userPrefsSoundFile]];
	}	
	
	[adhan setDelegate:self];
	[adhan play];
	
	//add mute adhan menu item 
	[appMenu insertItem:muteAdhan atIndex:0];
	[muteAdhan setTarget:self];
	[muteAdhan setAction:@selector(stopAdhan:)];
	
	//add seperator
	[appMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
}


/*
 * opens up help webpage 
 */
- (IBAction)getHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/help/"]];
}


/*
 * opens about window and puts it in front of all windows and apps
 */
- (IBAction)openAboutPanel:(id)sender
{
	[[AboutController sharedAboutWindowController] showWindow:nil];
	[[[AboutController sharedAboutWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	[[AboutController sharedAboutWindowController] setVersionText:[self getVersion]];
	[[AboutController sharedAboutWindowController] setBuildNumber:[self getBuildNumber]];
}


/*
 * load all the values from the user preferences file into variables
 */
- (void) loadDefaults
{	
	
	userPrefsSoundFile = [userDefaults integerForKey:@"SoundFile"];
	userPrefsUserSound = [userDefaults boolForKey:@"UserSound"];
	userPrefsUserSoundFile = [userDefaults stringForKey:@"UserSoundFile"];
	

	[todaysPrayerTimes setLatitude: [userDefaults floatForKey:@"Latitude"]];
	[todaysPrayerTimes setLongitude: [userDefaults floatForKey:@"Longitude"]];
	[todaysPrayerTimes setAsrMethod: [userDefaults integerForKey:@"AsrMethod"]];
	[todaysPrayerTimes setIshaMethod: [userDefaults integerForKey:@"IshaMethod"]];
	[todaysPrayerTimes setFajrMethod: [userDefaults integerForKey:@"FajrMethod"]];
	
	[todaysPrayerTimes setFajrOffset: [userDefaults integerForKey:@"FajrOffset"] - 15];
	[todaysPrayerTimes setShuruqOffset: [userDefaults integerForKey:@"ShuruqOffset"] - 15];
	[todaysPrayerTimes setDhuhurOffset: [userDefaults integerForKey:@"DhuhurOffset"] - 15];
	[todaysPrayerTimes setAsrOffset: [userDefaults integerForKey:@"AsrOffset"] - 15];
	[todaysPrayerTimes setMaghribOffset: [userDefaults integerForKey:@"MaghribOffset"] - 15];
	[todaysPrayerTimes setIshaOffset: [userDefaults integerForKey:@"IshaOffset"] - 15];
	
	
	if ([userDefaults boolForKey:@"EnableSound"])
	{
		//set adhan prefs
		[fajrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForFajr"]];
		[dhuhurPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForDhuhur"]];
		[asrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForAsr"]];
		[maghribPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForMaghrib"]];
		[ishaPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForIsha"]];
		shuruqReminder = [userDefaults boolForKey:@"ShuruqReminder"];
		minutesBeforeShuruq = [userDefaults integerForKey:@"MinutesBeforeShuruq"];
		tahajudReminder = [userDefaults boolForKey:@"FajrReminder"];
		minutesBeforeTahajud = [userDefaults integerForKey:@"MinutesBeforeFajr"];
	}
	else
	{
		[fajrPrayer setPlayAudio:NO];
		[dhuhurPrayer setPlayAudio:NO];
		[asrPrayer setPlayAudio:NO];
		[maghribPrayer setPlayAudio:NO];
		[ishaPrayer setPlayAudio:NO];
		shuruqReminder = NO;
		minutesBeforeShuruq = 0;
		tahajudReminder = NO;
		minutesBeforeTahajud = 0;		
	}
	
	preferencesVersion = [userDefaults integerForKey:@"PreferencesVersion"];
	displayGrowl = [userDefaults boolForKey:@"EnableGrowl"];
	stickyGrowl = [userDefaults boolForKey:@"StickyGrowl"];
	checkForUpdates = [userDefaults boolForKey:@"CheckForUpdates"];
	firstRun = [userDefaults boolForKey:@"FirstRun"];
	
	menuDisplayTime = [userDefaults integerForKey:@"DisplayNextPrayerTime"];
	menuDisplayName = [userDefaults integerForKey:@"DisplayNextPrayerName"];
	displayIcon = [userDefaults boolForKey:@"DisplayIcon"];
	displayNextPrayer = [userDefaults boolForKey:@"DisplayNextPrayer"];
}


/*
 * opens preferences window and puts it in front of all windows and apps
 */
- (IBAction)openPreferencesWindow:(id)sender
{	
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
}


/*
 * load user preferences into variables, caclulate and set prayer times, and recheck prayer times
 */
- (void) applyPrefs
{
	//get prefrences and load them into global vars
	[self loadDefaults]; 
	
	//recalculate and set the prayer times for each prayer object for today's date
	[self setPrayerTimes]; 
	
	//write the prayer times to the menu bar
	[self setMenuTimes]; 
	
	//recheck prayer times
	[self checkPrayerTimes]; 
}


/*
 * checks for new version based on the build number
 */
- (void) checkForUpdate:(BOOL)quiet
{
	int currentBuild = [self getBuildNumber];

	NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://guidanceapp.com/version.xml"]];
	int latestBuild = [[productVersionDict valueForKey:@"build"] intValue];
	NSString *latestVersionNumber = [productVersionDict valueForKey:@"version"];
    
	if([productVersionDict count] > 0 ) 
	{
		if(currentBuild == latestBuild && !quiet)
		{
			// tell user software is up to date
			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(NSLocalizedString(@"Your Software is up to date", @"Title of alert when a the user's software is up to date."),
				NSLocalizedString(@"You have the most recent version of Guidance.", @"Alert text when the user's software is up to date."),
				NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
		else if(currentBuild < latestBuild)
		{
			// tell user to download a new version
			[NSApp activateIgnoringOtherApps:YES];
			int button = NSRunAlertPanel(NSLocalizedString(@"A New Version is Available", @"Title of alert when a the user's software is not up to date."),
			[NSString stringWithFormat:NSLocalizedString(@"A new version of Guidance is available (version %@ r%i). Would you like to download the new version now?", @"Alert text when the user's software is not up to date."), latestVersionNumber,latestBuild],
				NSLocalizedString(@"OK", @"OK"),
				NSLocalizedString(@"Cancel", @"Cancel"), nil);
			if(NSOKButton == button)
			{
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/download/"]];
			}
		}
	} else if(!quiet) {
			// tell user unable to check for update
			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(NSLocalizedString(@"Unable to check for updates", @"Title of alert"),
				NSLocalizedString(@"Guidance is currently unable to check for updates.", @"Alert text"),
				NSLocalizedString(@"OK", @"OK"), nil, nil);
	}
}


/*
 * returns the version listed in CFBundleShortVersionString from Info.plist
 */
- (NSString *) getVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	
}


/*
 * returns the version listed in CFBundleVersion from Info.plist as an integer
 */
- (int) getBuildNumber
{
	NSString *buildString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	return [buildString intValue];
}


/*
 * returns true if any adhan is playing, otherwise false
 */
- (BOOL) isAdhanPlaying
{
	return [adhan isPlaying];
}



/*************************************
****** SINGLETON METHODS *************
*************************************/

+ (AppController*)sharedController
{
	@synchronized(self) {
		if (sharedAppController == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
    return sharedAppController;
}


+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedAppController == nil) {
            sharedAppController = [super allocWithZone:zone];
            return sharedAppController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}


- (void)release
{
    //do nothing
}

 
- (id)autorelease
{
    return self;
}



/*************************************
********** GROWL METHODS *************
*************************************/

/*
 * initialize growl and set the delegate as self
 */
- (id) init
{
	if ((self = [super init]))
	{
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	
	return self;
}


/*
 * register growl dictionary
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
		NSArray *notifications = [NSArray arrayWithObjects: NotificationName, nil];

		NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Guidance", GROWL_APP_NAME,
				notifications, GROWL_NOTIFICATIONS_ALL,
				notifications, GROWL_NOTIFICATIONS_DEFAULT,
				nil];

	return regDict;
}


/*
 * creates and displays a growl notification
 * @input String with the title of the notification
 * @input String with the description of the notification
 * @input boolean sticky status is true for sticky and false for normal
 * @input object context to pass back to the delegate when clicked
 * @input String optional identifying string is null for most cases
 */
- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier
{ 
	[GrowlApplicationBridge notifyWithTitle:title
					description:desc
					notificationName:NotificationName
					iconData: nil
					priority:0
					isSticky:sticky
					clickContext:clickContext
					identifier:identifier];
}


/*
 * called when a user clicks on a growl notification
 */
- (void) growlNotificationWasClicked:(id)clickContext 
{
	[self stopAdhan:nil];
}


/*
 * returns a boolean value indicating 
 * whether or not growl is installed
 * @return boolean yes if growl is installed or no if growl is not installed
 */ 
- (BOOL) isGrowlInstalled 
{
  return [GrowlApplicationBridge isGrowlInstalled];
}



/*************************************
********** SOUND METHODS *************
*************************************/

/*
 * sets currentlyPlayingAdhan to blank, removes sound icon, 
 * and removes mute adhan button and sets prayer items action to nothing
 */
- (void) sound:(NSSound *)sound didFinishPlaying:(BOOL)playbackSuccessful
{
	currentlyPlayingAdhan = @"";

	[self setStatusIcons];
	[[menuItems objectForKey:[currentPrayer getName]] setAction:@selector(doNothing:)];
	
	//remove "Mute Adhan" option
	if([appMenu indexOfItem:muteAdhan] > -1) {
		[appMenu removeItemAtIndex:[appMenu indexOfItem:muteAdhan]];
	}
	if([appMenu indexOfItem:fajrItem] != 0) [appMenu removeItemAtIndex:0];
}



@end


