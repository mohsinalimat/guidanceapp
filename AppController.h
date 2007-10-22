/* AppController */

#import <Cocoa/Cocoa.h>
#import "Growler.h"
#import "Prayer.h"

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
	
	Growler *MyGrowler;
	
	NSTimer *bootstrapTimer;
	NSTimer *timer;
}

- (void) handleBootstrapTimer;
- (void) handleTimer;
- (void) timeToPray;
- (void) initPrayers;
- (void) initGui;
- (void) setPrayerTimes;
@end
