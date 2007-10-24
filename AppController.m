#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	
	//store today's date
	today = [NSCalendarDate calendarDate];
	
	//initialize prayer objects with names
	[self initPrayers];
	
	//initialize prayer times object 
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	
	//set user latitude and longitude
	//currently hardcoded to raleigh
	[todaysPrayerTimes setLatitude: 35.776049];
	[todaysPrayerTimes setLongitude: -78.708552];
	
	//set prayer times
	[self setPrayerTimes];
	
	//create menu bar
	[self initGui];
	
	//initialize prayer time items in menu bar
	[self initPrayerItems];
	
	//create growl object
	MyGrowler = [[Growler alloc] init];
	
	//run once in case its time for prayer now
	[self handleTimer];

	//run bootstrapTimer so timer can run at 60 second intervals with the system clock
	bootstrapTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleBootstrapTimer) userInfo:nil repeats:YES];
}

- (void) initGui
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu];
	[menuBar setTitle:NSLocalizedString(@"Guidance",@"")];
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
	[todaysPrayerTimes calcTimes];
	
	//set times
	[fajrPrayer setTime: [todaysPrayerTimes getFajrTime]];
	[shuruqPrayer setTime: [todaysPrayerTimes getShuruqTime]];
	[dhuhurPrayer setTime: [todaysPrayerTimes getDhuhurTime]];
	[asrPrayer setTime: [todaysPrayerTimes getAsrTime]];
	[maghribPrayer setTime: [todaysPrayerTimes getMaghribTime]];
	[ishaPrayer setTime: [todaysPrayerTimes getIshaTime]];
}

- (void) handleBootstrapTimer
{
	if ([[NSCalendarDate calendarDate] secondOfMinute] == 0)
	{
		//check salah times
		[self handleTimer];
		
		//run 60 second timer to check for salah times
		timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
		[bootstrapTimer invalidate];
	}
}

- (void) handleTimer
{
	
    //get current time
	NSCalendarDate *currentTime = [NSCalendarDate calendarDate];
	NSCalendarDate *prayerTime;
	
	Prayer *prayers[] = {fajrPrayer,shuruqPrayer,dhuhurPrayer,asrPrayer,maghribPrayer,ishaPrayer};
	Prayer *prayer;
	
	
	//THIS LINE WILL NOT WORK WHEN RUN BY THE TIMER
	[MyGrowler doGrowl : [fajrPrayer getName] : [[fajrPrayer getTime] descriptionWithCalendarFormat: @"%1I:%M %p"] : NO];
	
	
	int i;
	for (i=0; i<6; i++)
	{
		BOOL display = YES;
		prayer = prayers[i];
		prayerTime = [prayer getTime];
		
		if ([prayerTime minuteOfHour] != [currentTime minuteOfHour]) display = NO;
		if ([prayerTime hourOfDay] != [currentTime hourOfDay]) display = NO;
		
		if (display)
		{
			NSString *name = [prayer getName];
			NSString *time = [prayer getFormattedTime];
			[MyGrowler doGrowl : name : [[time stringByAppendingString:@"\nIt's time to pray "] stringByAppendingString:name] : NO];
		}
	}
	
}


- (IBAction)selectPrayer:(id)sender {
	//do nothing for now
}

- (IBAction)donate:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ameir.com/ameir/donate/"]];
}

- (IBAction)openAboutPanel:(id)sender
{
    NSDictionary *options;
    NSImage *aboutImg;

    aboutImg = [NSImage imageNamed: @"aboutImg"];
    options = [NSDictionary dictionaryWithObjectsAndKeys:
          @"42", @"Version",
          @"Guidance", @"ApplicationName",
          aboutImg, @"ApplicationIcon",
          @"Copyright 2007, Batoul Apps", @"Copyright",
          @"Guidance v0.1a", @"ApplicationVersion",
         nil];

    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

@end

