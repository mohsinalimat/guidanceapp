#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	[self initPrayers];
	[self initGui];
	
	MyGrowler = [[Growler alloc] init];
	
	NSCalendarDate *now;
	now = [NSCalendarDate calendarDate];

	NSTimer *timer;
	timer = [NSTimer scheduledTimerWithTimeInterval:5
                                              target:self
                                            selector:@selector(handleTimer)
                                            userInfo:nil
                                            repeats:YES];
}

- (void) initGui
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
            menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
            [menuBar retain]; // keep it!
            [menuBar setTitle:NSLocalizedString(@"Menu",@"")]; // title
            [menuBar setHighlightMode:YES]; // behave like main menu
            [menuBar setMenu:appMenu]; // set submenu
	[menuBar setTitle:NSLocalizedString(@"Guidance",@"")]; // title
	
	[fajrItem setTitle:NSLocalizedString([@"Fajr:\t\t " stringByAppendingString:[fajrPrayer getFormattedTime]],@"")]; // title
	[shuruqItem setTitle:NSLocalizedString([@"Shuruq:\t\t " stringByAppendingString:[shuruqPrayer getFormattedTime]],@"")]; // title
	[dhuhurItem setTitle:NSLocalizedString([@"Dhuhur:\t\t " stringByAppendingString:[dhuhurPrayer getFormattedTime]],@"")]; // title
	[asrItem setTitle:NSLocalizedString([@"Asr:\t\t\t " stringByAppendingString:[asrPrayer getFormattedTime]],@"")]; // title
	[maghribItem setTitle:NSLocalizedString([@"Maghrib:\t " stringByAppendingString:[maghribPrayer getFormattedTime]],@"")]; // title
	[ishaItem setTitle:NSLocalizedString([@"Isha:\t\t " stringByAppendingString:[ishaPrayer getFormattedTime]],@"")]; // title
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

@end

