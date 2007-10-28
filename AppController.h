/* AppController */

#import <Cocoa/Cocoa.h>
#import "Growler.h"
#import "Prayer.h"
#import "PrayerTimes.h"

@interface AppController : NSObject
{	
	NSStatusItem *menuBar;
    IBOutlet NSMenu *appMenu;
	
	IBOutlet NSMenuItem *fajrItem;
	IBOutlet NSMenuItem *shuruqItem;
	IBOutlet NSMenuItem *dhuhurItem;
	IBOutlet NSMenuItem *asrItem;
	IBOutlet NSMenuItem *maghribItem;
	IBOutlet NSMenuItem *ishaItem;
	
	Prayer *fajrPrayer;
	Prayer *shuruqPrayer;
	Prayer *dhuhurPrayer;
	Prayer *asrPrayer;
	Prayer *maghribPrayer;
	Prayer *ishaPrayer;
	
	Prayer *nextPrayer;
	
	PrayerTimes *todaysPrayerTimes;
	
	Growler *MyGrowler;
	
	NSTimer *timer;
}
 
- (IBAction)selectPrayer:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)openAboutPanel:(id)sender;

- (void) handleTimer;

- (void) initPrayers;
- (void) initGui;
- (void) initPrayerItems;
- (void) setPrayerTimes;
- (void) setPrefs;
- (void) checkPrayerTimes;

@end
