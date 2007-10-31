#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];

	prayerTimeDate = [[NSCalendarDate calendarDate] retain];
	
	lastCheckTime = [[NSCalendarDate calendarDate] retain];

	//initialize prayer objects with names
	[self initPrayers];
	
	//initialize prayer times object 
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	
	//create growl object
	MyGrowler = [[Growler alloc] init];
	
	//call setPrefs
	//[self setPrefs];
	
	//set user latitude and longitude
	//currently hardcoded to raleigh
	[todaysPrayerTimes setLatitude: 35.776049];
	[todaysPrayerTimes setLongitude: -78.708552];
	
	//set prayer times
	[self setPrayerTimes];
	
	//initialize next prayer
	nextPrayer = fajrPrayer;
	
	//create menu bar
	[self initGui];
	
	//initialize prayer time items in menu bar
	[self initPrayerItems];
		
	//run once in case its time for prayer now
	[self checkPrayerTimes];

	//run timer to check for salah times		
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];	
}

- (void) initGui
{

	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	
	[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
	[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu];
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
	//init PrayerTimes object
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	
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
	
	[self setPrayerTimes];
}

- (void) setPrayerTimes
{
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
		[lastCheckTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:[NSCalendarDate calendarDate]];
		//NSLog(@"Seconds since last check: %d\n",seconds);
		
		
		if(seconds > 65) {
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
		[MyGrowler doGrowl : @"w00t" : @"new day" : NO];
		[self setPrayerTimes];
		[self initPrayerItems];
		
		//reset current day
		[prayerTimeDate release];
		prayerTimeDate = [[NSCalendarDate calendarDate] retain];
	}
	
	
	BOOL nextPrayerSet = NO;
	
	NSCalendarDate *prayerTime;
	int prayerHour, prayerMinute;
	
	Prayer *prayers[] = {fajrPrayer,shuruqPrayer,dhuhurPrayer,asrPrayer,maghribPrayer,ishaPrayer};
	Prayer *prayer;
	
	int i;
	for (i=0; i<6; i++)
	{
		BOOL display = YES;
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
			NSString *name = [prayer getName];
			NSString *time = [prayer getFormattedTime];
			
			//display growl
			[MyGrowler doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : NO];
			
			//play audio
			NSSound *adhan = [NSSound soundNamed:@"yusufislam"];
			[adhan play];
		}
	}
	
	
	NSString *nextPrayerLetter;
	int hourCount,minuteCount,secondsCount;
	
	if(nextPrayerSet == NO) {
		nextPrayerLetter = @"F";
		[todaysPrayerTimes calcTimes:[[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0]];
		[[[todaysPrayerTimes getFajrTime] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0] years:NULL months:NULL days:NULL  hours:&hourCount minutes:&minuteCount seconds:&secondsCount sinceDate:[NSCalendarDate calendarDate]];
		
	} else { 
		[[nextPrayer getTime] years:NULL months:NULL days:NULL  hours:&hourCount minutes:&minuteCount seconds:&secondsCount sinceDate:[NSCalendarDate calendarDate]];
		nextPrayerLetter = [[nextPrayer getName] substringToIndex:1];
	}
	
	if(secondsCount > 0) {
		if(minuteCount == 59) {
			hourCount++;
			minuteCount = 0;
		} else {
			minuteCount++;
		}
	}
	
	NSString *nextPrayerCount = [NSString stringWithFormat:@" %d:%02d",hourCount,minuteCount];
	
	[menuBar setImage: [NSImage imageNamed: @"menuBarFajr"]];
	[menuBar setTitle:NSLocalizedString([nextPrayerLetter stringByAppendingString:nextPrayerCount],@"")];
	
}

- (IBAction)selectPrayer:(id)sender 
{
	//do nothing for now
}

- (IBAction)donate:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ameir.com/ameir/donate/"]];
}

- (IBAction)openAboutPanel:(id)sender
{
    NSDictionary *options;
    NSImage *aboutImg;

    aboutImg = [NSImage imageNamed: @"guidanceIcon"];
    options = [NSDictionary dictionaryWithObjectsAndKeys:
          @"42", @"Version",
          @"Guidance", @"ApplicationName",
          aboutImg, @"ApplicationIcon",
          @"Copyright 2007, Batoul Apps", @"Copyright",
          @"Guidance v0.1a", @"ApplicationVersion",
         nil];

    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

- (void) setPrefs
{
	NSURL *coordinatesURL = [NSURL URLWithString:@"http://ayaconcepts.com/geocode.php?city=raleigh&state=nc"];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:coordinatesURL];
	if([xmlParser parse]) {
		//[MyGrowler doGrowl : @"Guidance" : @"XML Parsed!" : NO];
	} else {
		//[MyGrowler doGrowl : @"Guidance" : @"XML Could Not Parse!" : NO];
	}
}

- (IBAction)openPreferencesWindow:(id)sender
{
	[[PrefController sharedPrefsWindowController] showWindow:nil];
}

@end

