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

	/**********************/
	/*** CREATE OBJECTS ***/
	/**********************/
	
	//create user defaults object
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	prayerTimeDate = [[NSCalendarDate calendarDate] retain]; //set date with which to check prayer times
	
	lastCheckTime = [[NSCalendarDate calendarDate] retain]; //initialize last check time
	lastNotificationTime = [[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:0 hours:-1 minutes:0 seconds:0] retain]; //initialize last adhan time
	
	todaysPrayerTimes = [[PrayerTimes alloc] init]; //initialize prayer times object 

	
	[self initPrayers]; //create each prayer objects and set names 



	/****************************/
	/*** APPLICATION SETTINGS ***/
	/****************************/
	
	currentVersion = @"1.0";
	
	currentlyPlayingAdhan = @"";

	[self loadDefaults]; //load default preferences

	[self setPrayerTimes]; //sets each prayer object's prayer time
	
	
	
	/******************/	
	/*** CREATE GUI ***/
	/******************/
	
	[self initGui]; //create menu bar
	
	[self initPrayerItems]; //initialize prayer time items in menu bar	



	/***********************************/	
	/*** BEGIN CHECKING PRAYER TIMES ***/
	/***********************************/

	nextPrayer = fajrPrayer; //initially set next prayer to fajr

	[self checkPrayerTimes]; //initial prayer time check
			
	//run timer to check for salah times		
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];		
	
	
	
	/*********************/	
	/*** STARTUP TASKS ***/
	/*********************/
	
	//check if growl is installed
	if(![self isGrowlInstalled]) {
		[self doGrowl : @"Guidance" : @"Request Growl installation" : NO : nil : nil];
	}
	
	[self checkForUpdate:YES]; //check for new version	

	if(firstRun) {
		[welcomeWindow makeKeyAndOrderFront:nil]; //open welcome window
		[NSApp activateIgnoringOtherApps:YES];
	}
	
}


- (void) initGui
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


- (void) initPrayerItems
{
	[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t " stringByAppendingString:[fajrPrayer getFormattedTime]],@"")];
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")];
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")];
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")];
}

- (void) initPrayers
{
	//init Prayer objects
	fajrPrayer = [[Prayer alloc] init];
	shuruqPrayer = [[Prayer alloc] init];
	dhuhurPrayer = [[Prayer alloc] init];
	asrPrayer = [[Prayer alloc] init];
	maghribPrayer = [[Prayer alloc] init];
	ishaPrayer = [[Prayer alloc] init];
	tomorrowFajrPrayer = [[Prayer alloc] init];
	
	//init prayers array	
	prayersArray = [[NSDictionary dictionaryWithObjectsAndKeys:
				fajrPrayer,		@"0", 
				shuruqPrayer,	@"1", 
				dhuhurPrayer,	@"2",
				asrPrayer,		@"3",
				maghribPrayer,	@"4",
				ishaPrayer,		@"5",
				nil] retain];
	
	//set names
	[fajrPrayer setName: @"Fajr"];
	[shuruqPrayer setName: @"Shuruq"];
	[dhuhurPrayer setName: @"Dhuhur"];
	[asrPrayer setName: @"Asr"];
	[maghribPrayer setName: @"Maghrib"];
	[ishaPrayer setName: @"Isha"];
	[tomorrowFajrPrayer setName: @"Fajr"];
}



- (void) setPrayerTimes
{
	//calculate prayer times for current date
	[todaysPrayerTimes calcTimes:[NSCalendarDate calendarDate]];
	
	//set times
	[fajrPrayer setTime: [todaysPrayerTimes getFajrTime]];
	[shuruqPrayer setTime: [todaysPrayerTimes getShuruqTime]];
	[dhuhurPrayer setTime: [todaysPrayerTimes getDhuhurTime]];
	[asrPrayer setTime: [todaysPrayerTimes getAsrTime]];
	[maghribPrayer setTime: [todaysPrayerTimes getMaghribTime]];
	[ishaPrayer setTime: [todaysPrayerTimes getIshaTime]];
}

- (void) handleTimer
{	

	if([[NSCalendarDate calendarDate] secondOfMinute] == 0)
	{
		[self checkPrayerTimes];
	} else {
		int seconds;
		[[NSCalendarDate calendarDate] years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:lastCheckTime];
		
		if(seconds > 65 || seconds < 0) {
			[self checkPrayerTimes];
		}
	}
	
	if(![currentlyPlayingAdhan isEqualTo:@""]) {
		if(![self isAdhanPlaying]) [self stopAdhan:nil];
	}
}


- (void) setMenuBar: (BOOL) currentlyPrayerTime
{

	/* SET MENU BAR DISPLAY */
	
	NSString *menuBarTitle;
	
	if(displayIcon) {
		[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
		[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
	} else {
		[menuBar setImage: nil];
		[menuBar setAlternateImage: nil];
	}
	
	
	if(displayNextPrayer) {
	
		NSString *nextPrayerNameDisplay;
		NSString *nextPrayerTimeDisplay;
		
		
		if(menuDisplayName == 0) {
		
			nextPrayerNameDisplay = [nextPrayer getName]; //display whole name
			
		} else if(menuDisplayName == 1) {
		
			nextPrayerNameDisplay = [[nextPrayer getName] substringToIndex:1]; //display abbreviation
		
		}
		
	
		if(menuDisplayTime == 0) {
		
			nextPrayerTimeDisplay = [[nextPrayer getTime] descriptionWithCalendarFormat: @" %1I:%M"]; //display next prayer time
		
		} else if(menuDisplayTime == 1) {
		
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
			
		} 
		
		menuBarTitle = [nextPrayerNameDisplay stringByAppendingString:nextPrayerTimeDisplay];
		
	} else {
	
			menuBarTitle = @"";
	
	}
	
	//if its time to pray change the menu bar title to "prayer name" time for that minute
	if(currentlyPrayerTime) {
		menuBarTitle = [[currentPrayer getName] stringByAppendingString:@" time"];
	}
	
	[menuBar setTitle:NSLocalizedString(menuBarTitle,@"")]; //set menu bar title


}


- (void) setStatusIcons
{

	BOOL nextPrayerSet = NO;
	
	NSCalendarDate *prayerTime;
	NSString *prayerName, *stillTimeToPray;
	
	int i, secondsTill;
	
	for (i=0; i<6; i++)
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


- (void) checkPrayerTimes
{
	//update last time prayer times were checked
	[lastCheckTime release];
	lastCheckTime = [[NSCalendarDate calendarDate] retain];
	
	//if new day, update prayer times first
	if([[NSCalendarDate calendarDate] dayOfCommonEra] != [prayerTimeDate dayOfCommonEra]) {
		[self setPrayerTimes];
		[self initPrayerItems];
		
		//reset current day
		[prayerTimeDate release];
		prayerTimeDate = [[NSCalendarDate calendarDate] retain];
		
		//and if set, check for updates
		if(checkForUpdates) {
			[self checkForUpdate:YES];
		}
	}
	
	
	BOOL nextPrayerSet = NO;
	BOOL currentlyPrayerTime = NO;
	
	NSCalendarDate *prayerTime;
	
	Prayer *prayer;
	NSString *name, *time;
	int i, secondsTill, minutesTill, minuteSecondsTill;
	
	for (i=0; i<6; i++)
	{
		prayer = [prayersArray objectForKey:[NSString stringWithFormat:@"%d",i]];
		prayerTime = [prayer getTime];

		[prayerTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&secondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		[prayerTime years:NULL months:NULL days:NULL  hours:NULL minutes:&minutesTill seconds:&minuteSecondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		if(minuteSecondsTill > 0) minutesTill++; //round minute up
		
		
		//Get next prayer
		if(secondsTill > 0 && nextPrayerSet == NO)
		{
			nextPrayer = prayer;
			nextPrayerSet = YES;
		}

		int secondsSinceNotification;
		[[NSCalendarDate calendarDate] years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&secondsSinceNotification sinceDate:lastNotificationTime];		
		
		//check if its currently prayer time
		if ((secondsTill >= -58 && secondsTill <= 0) && ![[prayer getName] isEqualTo:@"Shuruq"])
		{
			currentPrayer = prayer;
			currentlyPrayerTime = YES;
			name = [prayer getName];
			time = [prayer getFormattedTime];
			
			BOOL notified = NO;

			//display growl
			if(displayGrowl  && !(secondsSinceNotification < 60 && secondsSinceNotification > 0)) 
			{
				[self doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : stickyGrowl : @"" : name];
				notified = YES;
			}
			
			//play audio
			if([prayer getPlayAudio]  && !(secondsSinceNotification < 60 && secondsSinceNotification > 0))
			{	
				notified = YES;
				
				if(![self isAdhanPlaying]) {
					[adhan play];
					
					//set mute adhan menu item and seperator
					[appMenu insertItem:muteAdhan atIndex:0];
					[muteAdhan setTarget:self];
					[muteAdhan setAction:@selector(stopAdhan:)];
					
					
					[appMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
					
				}
				
				currentlyPlayingAdhan = name;
				[[menuItems objectForKey:name] setAction:@selector(stopAdhan:)];	
					
			}
			
			if(notified) {
				//update last time user was notified
				[lastNotificationTime release];
				lastNotificationTime = [[NSCalendarDate calendarDate] retain];
			}
		} 
		else if(shuruqReminder && (minutesBeforeShuruq == minutesTill) && ([[prayer getName] isEqualTo:@"Shuruq"])  && !(secondsSinceNotification < 60 && secondsSinceNotification > 0))
		{
			currentPrayer = prayer;
			
			if(![self isAdhanPlaying]) {
				[adhan play];

				//set menu adhan menu item and seperator
				[appMenu insertItem:muteAdhan atIndex:0];
				[muteAdhan setTarget:self];
				[muteAdhan setAction:@selector(stopAdhan:)];
				[appMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
			}
			
			if(displayGrowl) [self doGrowl : @"Shuruq" : [[[shuruqPrayer getFormattedTime] stringByAppendingString:[NSString stringWithFormat:@"\n%d",minutesBeforeShuruq]] stringByAppendingString:@" minutes left to pray Fajr"] : stickyGrowl : @"" : @"Shuruq"];
			
			currentlyPlayingAdhan = @"Shuruq";
			[[menuItems objectForKey:@"Shuruq"] setAction:@selector(stopAdhan:)];
			
			//update last time user was notified
			[lastNotificationTime release];
			lastNotificationTime = [[NSCalendarDate calendarDate] retain];
		}
	}
	
	
	if(nextPrayerSet == NO) {
	
		//calculate the time for tomorrow's fajr prayer
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
		[tomorrowFajrPrayer setTime:[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
	
		nextPrayer = tomorrowFajrPrayer;
	}
	
	[self setMenuBar : currentlyPrayerTime];
	[self setStatusIcons];
}




- (IBAction)doNothing:(id)sender 
{
	//absolutely nothing
}

- (IBAction)stopAdhan:(id)sender 
{

	//create NSSound objects
	NSSound *yusufAdhan = [NSSound soundNamed:@"yusufislam"];
	NSSound *aqsaAdhan = [NSSound soundNamed:@"alaqsa"];
	NSSound *istanbulAdhan = [NSSound soundNamed:@"istanbul"];
	NSSound *makkahAdhan = [NSSound soundNamed:@"makkah"];
	
	//stop NSSound objects
	[yusufAdhan stop];
	[aqsaAdhan stop];
	[istanbulAdhan stop];
	[makkahAdhan stop];
	
	currentlyPlayingAdhan = @"";

	[self setStatusIcons];
	[[menuItems objectForKey:[currentPrayer getName]] setAction:@selector(doNothing:)];
	
	//remove "Mute Adhan" option
	if([appMenu indexOfItem:muteAdhan] > -1) {
		[appMenu removeItemAtIndex:[appMenu indexOfItem:muteAdhan]];
	}
	if([appMenu indexOfItem:fajrItem] != 0) [appMenu removeItemAtIndex:0];
}


- (IBAction)donate:(id)sender 
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/donate/"]]; //go to the donate page
}

- (IBAction)getHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/help/"]]; //go to the help page
}

- (IBAction)openAboutPanel:(id)sender
{
	[[AboutController sharedAboutWindowController] showWindow:nil];
	[[[AboutController sharedAboutWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	[[AboutController sharedAboutWindowController] setVersionText:currentVersion];
}

- (void) loadDefaults
{	
	switch ([userDefaults integerForKey:@"Sound"])
	{
		case 1:		adhan = [NSSound soundNamed:@"alaqsa"]; break;
		case 2:		adhan = [NSSound soundNamed:@"istanbul"]; break;
		case 3:		adhan = [NSSound soundNamed:@"yusufislam"]; break;
		case 0:
		default:	adhan = [NSSound soundNamed:@"makkah"]; break;
	}

	[todaysPrayerTimes setLatitude: [userDefaults floatForKey:@"Latitude"]];
	[todaysPrayerTimes setLongitude: [userDefaults floatForKey:@"Longitude"]];
	[todaysPrayerTimes setAsrMethod: [userDefaults integerForKey:@"AsrMethod"]];
	[todaysPrayerTimes setIshaMethod: [userDefaults integerForKey:@"IshaMethod"]];
	
	if ([userDefaults boolForKey:@"EnableSound"])
	{
		//set adhan prefs
		[fajrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForFajr"]];
		[dhuhurPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForDhuhur"]];
		[asrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForAsr"]];
		[maghribPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForMaghrab"]];
		[ishaPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForIsha"]];
		shuruqReminder = [userDefaults boolForKey:@"ShuruqReminder"];
		minutesBeforeShuruq = [userDefaults integerForKey:@"MinutesBeforeShuruq"];
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
	}
	
		
	displayGrowl = [userDefaults boolForKey:@"EnableGrowl"];
	stickyGrowl = [userDefaults boolForKey:@"StickyGrowl"];
	checkForUpdates = [userDefaults boolForKey:@"CheckForUpdates"];
	firstRun = [userDefaults boolForKey:@"FirstRun"];
	
	menuDisplayTime = [userDefaults integerForKey:@"MenuDisplayTime"];
	menuDisplayName = [userDefaults integerForKey:@"MenuDisplayName"];
	displayIcon = [userDefaults boolForKey:@"DisplayIcon"];
	displayNextPrayer = [userDefaults boolForKey:@"DisplayNextPrayer"];
		
	//now that app has been run, set FirstRun to false
	[userDefaults setBool:NO forKey:@"FirstRun"];
}


- (IBAction)openPreferencesWindow:(id)sender
{	
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void) applyPrefs
{
	[self loadDefaults]; //get prefrences and load them into global vars
	
	[self setPrayerTimes]; //recalculate and set the prayer times for each prayer object
	
	[self initPrayerItems]; //rewrite the prayer times to the gui
	
	[self checkPrayerTimes]; //recheck prayer times
}


- (void) checkForUpdate:(BOOL)quiet
{
	NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://guidanceapp.com/version.xml"]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:@"version"];
    
	if([productVersionDict count] > 0 ) 
	{
		if([latestVersionNumber isEqualTo: currentVersion] && !quiet)
		{
			// tell user software is up to date
			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(NSLocalizedString(@"Your Software is up to date", @"Title of alert when a the user's software is up to date."),
				NSLocalizedString(@"You have the most recent version of Guidance.", @"Alert text when the user's software is up to date."),
				NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
		else if( ![latestVersionNumber isEqualTo: currentVersion])
		{
			// tell user to download a new version
			[NSApp activateIgnoringOtherApps:YES];
			int button = NSRunAlertPanel(NSLocalizedString(@"A New Version is Available", @"Title of alert when a the user's software is not up to date."),
			[NSString stringWithFormat:NSLocalizedString(@"A new version of Guidance is available (version %@). Would you like to download the new version now?", @"Alert text when the user's software is not up to date."), latestVersionNumber],
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


- (BOOL) isAdhanPlaying
{
	BOOL adhanPlaying = NO;

	if([[NSSound soundNamed:@"alaqsa"] isPlaying] ||
	[[NSSound soundNamed:@"istanbul"] isPlaying] ||
	[[NSSound soundNamed:@"yusufislam"] isPlaying] ||
	[[NSSound soundNamed:@"makkah"] isPlaying]) {
		adhanPlaying = YES;
	}
	
	return adhanPlaying;
}



- (IBAction)firstRunSetup:(id)sender 
{
	[welcomeWindow close];
	
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
		
		[userDefaults setValue:city forKey:@"SetCity"];
		[userDefaults setValue:state forKey:@"SetState"];
		[userDefaults setValue:country forKey:@"SetCountry"];
	
		[userDefaults setFloat:[[coordDict valueForKey:@"latitude"] doubleValue] forKey:@"Latitude"];
		[userDefaults setFloat:[[coordDict valueForKey:@"longitude"] doubleValue] forKey:@"Longitude"];	
	}
	else
	{
		NSAlert* alert = [NSAlert new];
		[alert setMessageText: @"Unable to set location"];
		[alert setInformativeText: @"Guidance was unable to set the location you provided. Please go to the preferences and sit a different location or enter in the latitude and longitude manually."];
		[alert runModal];
		
		[userDefaults setFloat:0.00 forKey:@"Latitude"];
		[userDefaults setFloat:0.00 forKey:@"Longitude"];	
	}
	
	[userDefaults setValue:[userDefaults valueForKey:@"SetCity"] forKey:@"LocCity"];
	[userDefaults setValue:[userDefaults valueForKey:@"SetState"] forKey:@"LocState"];
	[userDefaults setValue:[userDefaults valueForKey:@"SetCountry"] forKey:@"LocCountry"];
	
	[self applyPrefs];
}


- (IBAction)startAtLogin:(id)sender
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


- (id) init
{
	if ((self = [super init]))
	{
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	
	return self;
}



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



- (void) growlNotificationWasClicked:(id)clickContext 
{
	[self stopAdhan:nil];
}


- (BOOL) isGrowlInstalled 
{
  return [GrowlApplicationBridge isGrowlInstalled];
}











@end


