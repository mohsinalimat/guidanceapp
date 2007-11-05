//
//  AppController.m
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "AppController.h"

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
		
	[guidanceVersion setStringValue:@"Version 0.2a"]; //set application version

	[self loadDefaults]; //load default preferences


	
	/**********************************/
	/*** PRAYER TIME INITIALIZATION ***/
	/**********************************/
	
	//sets each prayer object's prayer time
	[self setPrayerTimes];
	
	
	
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
}

- (void) initGui
{

	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	
	[menuBar setTitle:NSLocalizedString(@"☪" ,@"")];
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu];
	
	//[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
	//[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
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
		
		if ([prayerTime minuteOfHour] != [currentTime minuteOfHour]) display = NO;
		if ([prayerTime hourOfDay] != [currentTime hourOfDay]) display = NO;
		
		
		if (display)
		{
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
			}
		}
	}
	
	
	NSString *nextPrayerLetter;
	int hourCount,minuteCount,secondsCount;
	
	if(nextPrayerSet == NO) {
		nextPrayerLetter = @"F";
		
		//calculate the time for tomorrow's fajr prayer
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
		
		//get time until tomorrows fajr prayer
		[[[todaysPrayerTimes getFajrTime] 
			dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0] 
			years:NULL months:NULL days:NULL  hours:&hourCount minutes:&minuteCount seconds:&secondsCount 
			sinceDate:[NSCalendarDate calendarDate]];
		
	} else {
		//calculate time until next prayer
		[[nextPrayer getTime] 
			years:NULL months:NULL days:NULL  hours:&hourCount minutes:&minuteCount seconds:&secondsCount 
			sinceDate:[NSCalendarDate calendarDate]];
			
		nextPrayerLetter = [[nextPrayer getName] substringToIndex:1];
	}
	
	//round the seconds up
	if(secondsCount > 0) {
		if(minuteCount == 59) {
			hourCount++;
			minuteCount = 0;
		} else {
			minuteCount++;
		}
	}
	
	NSString *nextPrayerCount = [NSString stringWithFormat:@" %d:%02d",hourCount,minuteCount];
	
	[menuBar setTitle:NSLocalizedString([@"☪ " stringByAppendingString:[nextPrayerLetter stringByAppendingString:nextPrayerCount]],@"")];
	

	//if its time to pray change the menu bar title to "prayer name" time for that minute
	if(currentlyPrayerTime) {
		[menuBar setTitle:NSLocalizedString([name stringByAppendingString:@" time"],@"")];
	}
	
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
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ameir.com/ameir/donate/"]]; //go to donate page
}

- (IBAction)website:(id)sender 
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/"]]; //go to Guidance website
}

- (IBAction)openAboutPanel:(id)sender
{
	[aboutGuidance orderFrontRegardless];
}

- (void) loadDefaults
{
	NSLog(@"LOADING DEFAULTS!");

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
	
	
	//set adhan prefs
	[fajrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForFajr"]];
	[shuruqPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForShuruq"]];
	[dhuhurPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForDhuhur"]];
	[asrPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForAsr"]];
	[maghribPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForMaghrab"]];
	[ishaPrayer setPlayAudio: [userDefaults boolForKey:@"PlayAdhanForIsha"]];
	
	
	displayGrowl = [userDefaults boolForKey:@"EnableGrowl"];
	stickyGrowl = [userDefaults boolForKey:@"StickyGrowl"];
	
	/*
	NSURL *coordinatesURL = [NSURL URLWithString:@"http://guidanceapp.com/location.php?city=raleigh&state=nc"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:coordinatesURL];
	if([xmlParser parse]) {
		//[MyGrowler doGrowl : @"Guidance" : @"XML Parsed!" : NO];
	} else {
		//[MyGrowler doGrowl : @"Guidance" : @"XML Could Not Parse!" : NO];
	}
	*/
}

- (IBAction)openPreferencesWindow:(id)sender
{
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] orderFrontRegardless];
}

/*************************************
****** SINGLETON METHODS *************
*************************************/

static AppController *sharedAppController = nil;

+ (AppController*)sharedController
{
    @synchronized(self) {
        if (sharedAppController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedAppController;
}

/*+ (id)allocWithZone:(NSZone *)zone
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
}*/

@end

