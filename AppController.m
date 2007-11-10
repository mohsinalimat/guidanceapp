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
	
	currentVersion = @"0.2";

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
	
	
	
	[self checkForUpdate:YES]; //check for new version
	

	if(firstRun) {
		//open welcome window
		[welcomeWindow orderFrontRegardless];
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
}


- (void) initPrayerItems
{

	[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t " stringByAppendingString:[fajrPrayer getFormattedTime]],@"")];
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")];
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")];
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")];
	
	//[asrItem setImage: [NSImage imageNamed: @"speaker"]];
	//[asrItem setTitle:NSLocalizedString([@"♫ " stringByAppendingString:[asrItem title]],@"")];
	//[asrItem setAlternateImage: [NSImage imageNamed: @"altspeaker"]];
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
	
	//set names
	[fajrPrayer setName: @"Fajr"];
	[shuruqPrayer setName: @"Shuruq"];
	[dhuhurPrayer setName: @"Dhuhur"];
	[asrPrayer setName: @"Asr"];
	[maghribPrayer setName: @"Maghrib"];
	[ishaPrayer setName: @"Isha"];
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
	int currentHour = [currentTime hourOfDay];
	int currentMinute = [currentTime minuteOfHour];
	int currentTimeDecimal = (currentHour*60) + currentMinute;
	
	
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
	int prayerHour, prayerMinute;
	
	Prayer *prayers[] = {fajrPrayer,shuruqPrayer,dhuhurPrayer,asrPrayer,maghribPrayer,ishaPrayer};
	Prayer *prayer;
	BOOL display;
	NSString *name;
	NSString *time;
	int i;
	
	for (i=0; i<6; i++)
	{
		display = YES;
		prayer = prayers[i];
		prayerTime = [prayer getTime];
		prayerHour = [prayerTime hourOfDay];
		prayerMinute = [prayerTime minuteOfHour];
		int prayerTimeDecimal = (prayerHour*60) + prayerMinute;

		if(prayerTimeDecimal > currentTimeDecimal && nextPrayerSet == NO)
		{
			nextPrayer = prayer;
			nextPrayerSet = YES;
		}
		
		if (([prayerTime minuteOfHour] != [currentTime minuteOfHour]) || ([prayerTime hourOfDay] != [currentTime hourOfDay])) display = NO;
		
		if (display)
		{
			currentlyPrayerTime = YES;
			name = [prayer getName];
			time = [prayer getFormattedTime];
			
			
			//display growl
			if(displayGrowl) 
			{
				[MyGrowler doGrowl : name : [[time stringByAppendingString:@"\nIt's time for "] stringByAppendingString:name] : stickyGrowl : adhanFile];
			}
			
			//play audio
			if([prayer getPlayAudio])
			{	
				[[NSSound soundNamed:adhanFile] play];
			}
		}
	}
	
	
	
	if(nextPrayerSet == NO) {
	
		//calculate the time for tomorrow's fajr prayer
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
	
		[nextPrayer setName:@"Fajr"];
		
		[nextPrayer setTime:[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
	}
	
	
	NSString *menuBarTitle;
	
	
	/* SET MENU BAR DISPLAY */
	
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
		
			nextPrayerNameDisplay = [nextPrayer getName];	
			
		} else if(menuDisplayName == 1) {
		
			nextPrayerNameDisplay = [[nextPrayer getName] substringToIndex:1];
		
		}
		
	
		if(menuDisplayTime == 0) {
		
			nextPrayerTimeDisplay = [[nextPrayer getTime] descriptionWithCalendarFormat: @" %1I:%M"];
		
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
			
			nextPrayerTimeDisplay = [NSString stringWithFormat:@" %d:%02d",hourCount,minuteCount];
			
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
}

- (IBAction)selectPrayer:(id)sender 
{	
	[[NSSound soundNamed:adhanFile] stop];
}

- (IBAction)donate:(id)sender 
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/donate/"]]; //go to the donate page
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
		[shuruqPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForShuruq"]];
		[dhuhurPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForDhuhur"]];
		[asrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForAsr"]];
		[maghribPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForMaghrab"]];
		[ishaPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForIsha"]];
	}
	else
	{
		[fajrPrayer setPlayAudio:NO];
		[shuruqPrayer setPlayAudio:NO];
		[dhuhurPrayer setPlayAudio:NO];
		[asrPrayer setPlayAudio:NO];
		[maghribPrayer setPlayAudio:NO];
		[ishaPrayer setPlayAudio:NO];
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
	NSLog(@"PlayAdhanForShuruq: %d", [userDefaults boolForKey:@"PlayAdhanForShuruq"]);
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

