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
	
	prayerTimeDate = [[NSCalendarDate calendarDate] retain]; //set date with which to check prayer times
	
	lastCheckTime = [[NSCalendarDate calendarDate] retain]; //initialize last check time

	MyGrowler = [[Growler alloc] init]; //create growl object
	
	todaysPrayerTimes = [[PrayerTimes alloc] init]; //initialize prayer times object 
	
	//check if growl is installed
	if(![MyGrowler  isInstalled]) {
		[MyGrowler doGrowl : @"Guidance" : @"Request Growl installation" : NO : nil];
	}
	
	[self initPrayers]; //create each prayer objects and set names 



	/****************************/
	/*** APPLICATION SETTINGS ***/
	/****************************/
	
	currentVersion = @"0.1a";

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
	
	[self checkForUpdate:YES]; //check for new version	

	if(firstRun) {
		[welcomeWindow orderFrontRegardless]; //open welcome window
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
}


- (void) initPrayerItems
{

	[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t " stringByAppendingString:[fajrPrayer getFormattedTime]],@"")];
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")];
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")];
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")];



	/*
	//[fajrItem setImage: [NSImage imageNamed: @"typing"]];
	//[shuruqItem setImage: [NSImage imageNamed: @"sound"]];

	[fajrItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[shuruqItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[dhuhurItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[asrItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[maghribItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[ishaItem setImage: [NSImage imageNamed: @"status_notTime"]];
	[asrItem setTitle:NSLocalizedString([@"♫ " stringByAppendingString:[asrItem title]],@"")];
	//[asrItem setAlternateImage: [NSImage imageNamed: @"altspeaker"]];
	*/

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
}

- (void) checkPrayerTimes
{
	[lastCheckTime release];
	lastCheckTime = [[NSCalendarDate calendarDate] retain];
	
	NSCalendarDate *currentTime = [NSCalendarDate calendarDate];
	
	
	//if new day, update prayer times
	if([currentTime dayOfCommonEra] != [prayerTimeDate dayOfCommonEra]) {
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
	
	Prayer *prayers[] = {fajrPrayer,shuruqPrayer,dhuhurPrayer,asrPrayer,maghribPrayer,ishaPrayer};
	Prayer *prayer;
	NSString *name, *time, *stillTimeToPray;
	int i, secondsTill, minutesTill, minuteSecondsTill;
	
	for (i=0; i<6; i++)
	{
		prayer = [prayersArray objectForKey:[NSString stringWithFormat:@"%d",i]];
		prayerTime = [prayer getTime];

		[prayerTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&secondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		[prayerTime years:NULL months:NULL days:NULL  hours:NULL minutes:&minutesTill seconds:&minuteSecondsTill sinceDate:[NSCalendarDate calendarDate]];
		
		if(minuteSecondsTill > 0) minutesTill++;
		
		[[menuItems objectForKey:[prayer getName]] setImage: [NSImage imageNamed: @"status_notTime"]];
		
		
		/*
		NSLog(@"%@ (array val of %@ for %d) in %d seconds",[prayer getName], [prayers[i] getName], i, secondsTill);
		*/
		
		//Get next prayer
		if(secondsTill > 0 && nextPrayerSet == NO)
		{
			nextPrayer = prayer;
			nextPrayerSet = YES;
			
			/*
			NSLog(@"the next prayer is %@",[prayers[i] getName]);
			*/
			
			if(i == 0) {
				stillTimeToPray = [prayers[5] getName];
			} else if(i == 1) {
				stillTimeToPray = [prayers[0] getName];
			} else if(i == 2) {
				stillTimeToPray = @"";
			} else {
				stillTimeToPray = [prayers[i-1] getName];
			}
		}
		
		
		//check if its currently prayer time
		if ((secondsTill >= -58 && secondsTill <= 0) && ![[prayer getName] isEqualTo:@"Shuruq"])
		{
			currentPrayer = prayer;
			currentlyPrayerTime = YES;
			name = [prayer getName];
			time = [prayer getFormattedTime];
			
			//display growl
			if(displayGrowl) 
			{
				[MyGrowler doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : stickyGrowl : adhanFile];
			}
			
			//play audio
			if([prayer getPlayAudio])
			{	
				[[NSSound soundNamed:adhanFile] play];
				[[menuItems objectForKey:name] setImage: [NSImage imageNamed: @"status_sound"]];
				[[menuItems objectForKey:name] setAction:@selector(stopAdhan:)];
			}
		} 
		else if(shuruqReminder && (minutesBeforeShuruq == minutesTill) && ([[prayer getName] isEqualTo:@"Shuruq"]))
		{
			currentPrayer = prayer;
			[[NSSound soundNamed:adhanFile] play];
			[MyGrowler doGrowl : @"Shuruq" : [[[shuruqPrayer getFormattedTime] stringByAppendingString:[NSString stringWithFormat:@"\n%d",minutesBeforeShuruq]] stringByAppendingString:@" minutes left to pray Fajr"] : stickyGrowl : adhanFile];
			[[menuItems objectForKey:@"Shuruq"] setImage: [NSImage imageNamed: @"status_sound"]];
			[[menuItems objectForKey:@"Shuruq"] setAction:@selector(stopAdhan:)];
		}
	}
	
	
	if(nextPrayerSet == NO) {
	
		//calculate the time for tomorrow's fajr prayer
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
		[tomorrowFajrPrayer setTime:[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
	
		nextPrayer = tomorrowFajrPrayer;
		stillTimeToPray = @"Isha";
	}
	
	
	//set green dot status that shows its still to pray that prayer
	if(![stillTimeToPray isEqualTo:@""]) {
		if(![[[[menuItems objectForKey:stillTimeToPray] image] name] isEqualTo:@"status_sound"]) {
			[[menuItems objectForKey:stillTimeToPray] setImage: [NSImage imageNamed: @"status_prayerTime"]];
		}
	}
		
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
		menuBarTitle = [name stringByAppendingString:@" time"];
	}
	
	
	[menuBar setTitle:NSLocalizedString(menuBarTitle,@"")]; //set menu bar title
	
	
	
}

- (IBAction)doNothing:(id)sender 
{
	//absolutely nothing
	//[MyGrowler doGrowl : @"test" : @"im doing nothin" : NO : nil];
}

- (IBAction)stopAdhan:(id)sender 
{
	NSSound *adhanToStop = [NSSound soundNamed:adhanFile];
	[adhanToStop stop];
	
	if([[currentPrayer getName] isEqualTo:@"Shuruq"]) {
		[[menuItems objectForKey:[currentPrayer getName]] setImage: [NSImage imageNamed: @"status_notTime"]];
	} else {
		[[menuItems objectForKey:[currentPrayer getName]] setImage: [NSImage imageNamed: @"status_prayerTime"]];
	}
	[[menuItems objectForKey:[currentPrayer getName]] setAction:@selector(doNothing:)];
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
	[[[AboutController sharedAboutWindowController] window] orderFrontRegardless];
	[[AboutController sharedAboutWindowController] setVersionText:currentVersion];
}

- (void) loadDefaults
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	switch ([userDefaults integerForKey:@"Sound"])
	{
		case 1:		adhanFile = @"alaqsa"; break;
		case 2:		adhanFile = @"istanbul"; break;
		case 3:		adhanFile = @"yusufislam"; break;
		case 0:
		default:	adhanFile = @"makkah"; break;
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
	
	
	/*
	NSLog(@"Latitude: %f", [userDefaults floatForKey:@"Latitude"]);
	NSLog(@"Longitude: %f", [userDefaults floatForKey:@"Longitude"]);
	NSLog(@"AsrMethod: %d", [userDefaults integerForKey:@"AsrMethod"]);
	NSLog(@"IshaMethod: %d", [userDefaults integerForKey:@"IshaMethod"]);
	
	
	NSLog(@"EnableSound: %d", [userDefaults boolForKey:@"EnableSound"]);
	
	NSLog(@"PlayAdhanForFajr: %d", [userDefaults boolForKey:@"PlayAdhanForFajr"]);
	NSLog(@"PlayAdhanForDhuhur: %d", [userDefaults boolForKey:@"PlayAdhanForDhuhur"]);
	NSLog(@"PlayAdhanForAsr: %d", [userDefaults boolForKey:@"PlayAdhanForAsr"]);
	NSLog(@"PlayAdhanForMaghrab: %d", [userDefaults boolForKey:@"PlayAdhanForMaghrab"]);
	NSLog(@"PlayAdhanForIsha: %d", [userDefaults boolForKey:@"PlayAdhanForIsha"]);
	
	
	NSLog(@"EnableGrowl: %d", [userDefaults boolForKey:@"EnableGrowl"]);
	NSLog(@"StickyGrowl: %d", [userDefaults boolForKey:@"StickyGrowl"]);
	NSLog(@"CheckForUpdates: %d", [userDefaults boolForKey:@"CheckForUpdates"]);
	NSLog(@"FirstRun: %d", [userDefaults boolForKey:@"FirstRun"]);
	NSLog(@" ");
	*/

}

- (IBAction)openPreferencesWindow:(id)sender
{
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] orderFrontRegardless];
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
			NSRunAlertPanel(NSLocalizedString(@"Your Software is up-to-date", @"Title of alert when a the user's software is up to date."),
				NSLocalizedString(@"You have the most recent version of Guidance.", @"Alert text when the user's software is up to date."),
				NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
		else if( ![latestVersionNumber isEqualTo: currentVersion])
		{
			// tell user to download a new version
			int button = NSRunAlertPanel(NSLocalizedString(@"A New Version is Available", @"Title of alert when a the user's software is not up to date."),
			[NSString stringWithFormat:NSLocalizedString(@"A new version of Guidance is available (version %@). Would you like to download the new version now?", @"Alert text when the user's software is not up to date."), latestVersionNumber],
				NSLocalizedString(@"OK", @"OK"),
				NSLocalizedString(@"Cancel", @"Cancel"), nil);
			if(NSOKButton == button)
			{
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/download/"]];
			}
		}
	}
}


- (IBAction)firstRunSetup:(id)sender 
{
	[welcomeWindow close];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	NSString *city = [cityText stringValue];
	NSString *state = [stateText stringValue];
	NSString *country = [countryText stringValue];
		
	NSString *safeCity =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) city, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	NSString *safeState =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) state, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	NSString *safeCountry =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) country, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://guidanceapp.com/location.php?city=%@&state=%@&country=%@",safeCity,safeState,safeCountry];
	NSDictionary *coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	BOOL valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	
	[userDefaults setValue:city forKey:@"LocCity"];
	[userDefaults setValue:state forKey:@"LocState"];
	[userDefaults setValue:country forKey:@"LocCountry"];

	
	if (valid)
	{
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
	
	[self applyPrefs];
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

@end

