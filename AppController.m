#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	[self initPrayers];
	[self initGui];
	[self setPrayerTimes];
	
	MyGrowler = [[Growler alloc] init];
	
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];

	bootstrapTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleBootstrapTimer) userInfo:nil repeats:YES];
}

- (void) initGui
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu]; // set menu items
	[menuBar setTitle:NSLocalizedString(@"Guidance",@"")]; // set title
}

- (void) setPrayerTimes
{
	//[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t",@"")]; 
	//stringByAppendingString:[fajrPrayer getFormattedTime]],@""
	[fajrItem setTitle:NSLocalizedString(@"Fajr:",@"")]; // set title
	//[fajrItem setIndentationLevel:3];
	//setAttributedTitle
	//[fajrItem setKeyEquivalent:NSLocalizedString(@"5:43 AM",@"")];
	
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")];
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")];
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
    //[self timeToPray];
	Prayer *MyPrayer;
	MyPrayer = [[Prayer alloc] init];
	[MyPrayer setName : @"Fajr"];
	[MyGrowler doGrowl : @"Guidance" : [MyPrayer getName] : NO];
}

- (void)timeToPray
{
	int alert = NSRunAlertPanel(@"Fajr",@"It is time to pray Fajr",@"Ok",@"Cancel",nil);
	NSLog(@"" + alert);
}

- (IBAction)selectPrayer:(id)sender {
	[self timeToPray];
}


@end

