#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	
	//store today's date
	today = [NSCalendarDate calendarDate];
	
	//initialize prayer objects with names
	[self initPrayers];
	
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

- (NSDictionary*)prayerFontAttributes {
	return [NSDictionary dictionaryWithObject: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]] forKey:NSFontAttributeName];

}


- (void) initPrayerItems
{
	//[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t",@"")]; 
	//stringByAppendingString:[fajrPrayer getFormattedTime]],@""
	//[fajrItem setTitle:NSLocalizedString(@"Fajr:",@"")]; // set title
	//[fajrItem setIndentationLevel:3];
	//setAttributedTitle
	//NSAttributedString *fajrString;
	//[fajrString initWithString:@"dude"];
	//[fajrItem setAttributedTitle:fajrString];
	//NSAttributedString
	//- (void)setAttributedTitle:(NSAttributedString *)title
	//[fajrItem setKeyEquivalent:NSLocalizedString(@"5:43 AM",@"")];
	
	
	NSAttributedString *fajrTitle = [[[NSAttributedString alloc] 
		initWithString:NSLocalizedString(@"Fajr",@"")
		attributes:[self prayerFontAttributes]] autorelease];
	
	
	[fajrItem setAttributedTitle:fajrTitle];
	
	NSString *shuruqFormattedName = [[shuruqPrayer getName] stringByPaddingToLength: 22-[[shuruqPrayer getFormattedTime] length] withString: @" " startingAtIndex:0];
	[shuruqItem setTitle:NSLocalizedString([shuruqFormattedName stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	
	NSString *dhuhurFormattedName = [[dhuhurPrayer getName] stringByPaddingToLength: 22-[[dhuhurPrayer getFormattedTime] length] withString: @" " startingAtIndex:0];
	[dhuhurItem setTitle:NSLocalizedString([dhuhurFormattedName stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
	
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")];
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")];
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")];
}

- (void) initPrayers
{
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
	/* DOES NOT WORK
	Prayer *prayers[] = {fajrPrayer, shuruqPrayer, dhuhurPrayer, asrPrayer, maghribPrayer, ishaPrayer};
	
	int i;
	for (i = 0; i < 6; i++)
	{
		NSString *name = @"Prayer Name " + (i+1);
		NSCalendarDate *time = [NSCalendarDate calendarDate];
		time = [time dateByAddingYears: 0 months: 0 days: 0 hours: 2*(i+1) minutes: 0 seconds: 0];
		[prayers[i] setName : name];
		[prayers[i] setTime : time];
	}
	*/
	
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	
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
		timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
		[bootstrapTimer invalidate];
	}
}

- (void) handleTimer
{
    //get current time
	NSCalendarDate *currentTime = [NSCalendarDate calendarDate];
	NSCalendarDate *shuruqTime = [shuruqPrayer getTime];
	
	if ([shuruqTime minuteOfHour] == [currentTime minuteOfHour]) {
		[MyGrowler doGrowl : @"Guidance" : [shuruqPrayer getName] : NO];	
	}
	
	
}

- (void)timeToPray
{
	int alert = NSRunAlertPanel(@"Fajr",@"It is time to pray Fajr",@"Ok",@"Cancel",nil);
	NSLog(@"" + alert);
}

- (IBAction)selectPrayer:(id)sender {
	[self timeToPray];
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
          @"0.1a", @"Version",
          @"Guidance", @"ApplicationName",
          aboutImg, @"ApplicationIcon",
          @"Copyright 2007, Batoul Apps", @"Copyright",
          @"Guidance v0.1a", @"ApplicationVersion",
         nil];

    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

@end

