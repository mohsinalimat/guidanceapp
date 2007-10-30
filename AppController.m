#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{	
	currentDate = [[NSCalendarDate calendarDate] retain];
	
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

/* TESTING
	int seconds;
	[lastCheckTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:currentDate];

	NSCalendarDate *someTime = [NSCalendarDate calendarDate];
	[someTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:lastCheckTime];


	if([[NSCalendarDate calendarDate] secondOfMinute] % 5 == 0)
	{
		[self checkPrayerTimes];
	} else {
		int seconds;
		[[NSCalendarDate calendarDate] years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:lastCheckTime];
		if(seconds > 62) {
			[self checkPrayerTimes];
		}
	}
*/

	if([[NSCalendarDate calendarDate] secondOfMinute] % 5 == 0)
	{
		[self checkPrayerTimes];
	}
}

- (void) checkPrayerTimes
{
	
	/* TESTING
	int seconds = 1;
	//[lastCheckTime years:NULL months:NULL days:NULL  hours:NULL minutes:NULL seconds:&seconds sinceDate:currentDate];
	lastCheckTime = [NSCalendarDate calendarDate];
	
	//[MyGrowler doGrowl : [NSString stringWithFormat:@"%d",seconds] : [lastCheckTime description] : NO];
	*/
	
	
	NSCalendarDate *currentTime = [NSCalendarDate calendarDate];
	int currentHour = [currentTime hourOfDay];
	int currentMinute = [currentTime minuteOfHour];
	int currentTimeDecimal = (currentHour*60) + currentMinute;
	
	//if new day, update prayer times
	if([currentTime dayOfMonth] != [currentDate dayOfMonth]) {
		[self setPrayerTimes];
		[self initPrayerItems];
		
		//reset current day
		[currentDate release];
		currentDate = [NSCalendarDate calendarDate];
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
			[MyGrowler doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : NO];
		}
	}
	
	
	int nextPrayerHour = [[nextPrayer getTime] hourOfDay];
	int nextPrayerMinute = [[nextPrayer getTime] minuteOfHour];
	int nextPrayerDecimal = (nextPrayerHour*60) + nextPrayerMinute;
	
	int decimalCount = nextPrayerDecimal - currentTimeDecimal;
	
	int hourCount = decimalCount/60;
	int minuteCount = decimalCount-(hourCount*60);
	

	NSString *nextPrayerLetter = [[nextPrayer getName] substringToIndex:1];
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

@end

