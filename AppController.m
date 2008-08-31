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
	//create user defaults object
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	[self createAppMenu];
	
	[self loadPreferences];
	
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	tomorrowsPrayerTimes = [[PrayerTimes alloc] init];
	[self setPrayerTimes];
	
	[self displayPrayerTimes];
	
	lastCheckTime = [[NSDate date] retain];
	[self checkPrayerStatus];
	
	//running loop that checks prayer times every second
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runLoop) userInfo:nil repeats:YES]; 
	
	
	//check if growl is installed
	if(![self isGrowlInstalled]) {
		[self doGrowl : @"Guidance" : @"Request Growl installation" : NO : nil : nil];
	}
	
	//check for new version
	[self checkForUpdate:YES]; 	
	
	// bring  up welcome window if this is the first time the program has been ran 
	// or if the preferences are incompatible
	if(firstRun || preferencesVersion < [self getBuildNumber]) {
		[[WelcomeController sharedWelcomeWindowController] showWindow:nil];
		[[[WelcomeController sharedWelcomeWindowController] window] makeKeyAndOrderFront:nil];
		[NSApp activateIgnoringOtherApps:YES];
		
		//now that app has been run, set FirstRun to false and set the proper preferences version
		[userDefaults setBool:NO forKey:@"FirstRun"];
		[userDefaults setInteger:[self getBuildNumber] forKey:@"PreferencesVersion"];
	}
}


- (void) createAppMenu
{
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuBar = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuBar retain];
	
	[menuBar setHighlightMode:YES];
	[menuBar setMenu:appMenu];
	
	[appMenu setAutoenablesItems:NO];
	
	// default all status icons to not time
	[fajrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[shuruqItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[dhuhurItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[asrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[maghribItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[ishaItem setImage:[NSImage imageNamed:@"status_notTime"]];
}


- (void) setPrayerTimes 
{
	
	[tomorrowsPrayerTimes setLatitude:latitude];
	[tomorrowsPrayerTimes setLongitude:longitude];
	
	[tomorrowsPrayerTimes setSystemTimezone:systemTimezone];
	[tomorrowsPrayerTimes setTimezone:timezone];
	[tomorrowsPrayerTimes setDaylightSavings:daylightSavings];
	
	[tomorrowsPrayerTimes setMadhab:madhab]; 
	[tomorrowsPrayerTimes setMethod:method];
	[tomorrowsPrayerTimes setCustomSunriseAngle:customSunriseAngle];
	[tomorrowsPrayerTimes setCustomSunsetAngle:customSunsetAngle];
	
	[tomorrowsPrayerTimes setFajrOffset:fajrOffset];
	[tomorrowsPrayerTimes setShuruqOffset:shuruqOffset];
	[tomorrowsPrayerTimes setDhuhurOffset:dhuhurOffset];
	[tomorrowsPrayerTimes setAsrOffset:asrOffset];
	[tomorrowsPrayerTimes setMaghribOffset:maghribOffset];
	[tomorrowsPrayerTimes setIshaOffset:ishaOffset];
	
	[tomorrowsPrayerTimes setDate:[NSDate dateWithTimeIntervalSinceNow:86400]];
	
	
	
	[todaysPrayerTimes setLatitude:latitude];
	[todaysPrayerTimes setLongitude:longitude];
	
	[todaysPrayerTimes setSystemTimezone:systemTimezone];
	[todaysPrayerTimes setTimezone:timezone];
	[todaysPrayerTimes setDaylightSavings:daylightSavings];
	
	[todaysPrayerTimes setMadhab:madhab]; 
	[todaysPrayerTimes setMethod:method];
	[todaysPrayerTimes setCustomSunriseAngle:customSunriseAngle];
	[todaysPrayerTimes setCustomSunsetAngle:customSunsetAngle];
	
	[todaysPrayerTimes setFajrOffset:fajrOffset];
	[todaysPrayerTimes setShuruqOffset:shuruqOffset];
	[todaysPrayerTimes setDhuhurOffset:dhuhurOffset];
	[todaysPrayerTimes setAsrOffset:asrOffset];
	[todaysPrayerTimes setMaghribOffset:maghribOffset];
	[todaysPrayerTimes setIshaOffset:ishaOffset];
	
	[todaysPrayerTimes setDate:[NSDate date]];
	currentDay = [[[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]] day];
	
	
	fajrTime = [[todaysPrayerTimes getFajrTime] retain];
	shuruqTime = [[todaysPrayerTimes getShuruqTime] retain];
	dhuhurTime = [[todaysPrayerTimes getDhuhurTime] retain];
	asrTime = [[todaysPrayerTimes getAsrTime] retain];
	maghribTime = [[todaysPrayerTimes getMaghribTime] retain];
	ishaTime = [[todaysPrayerTimes getIshaTime] retain];
	
	tomorrowFajrTime = [[tomorrowsPrayerTimes getFajrTime] retain];

}


- (void) displayPrayerTimes 
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	[fajrItem setTitle:[NSString stringWithFormat:@"Fajr:\t\t %@",[dateFormatter stringFromDate:fajrTime]]];
	[shuruqItem setTitle:[NSString stringWithFormat:@"Shuruq:\t\t %@",[dateFormatter stringFromDate:shuruqTime]]];
	[dhuhurItem setTitle:[NSString stringWithFormat:@"Dhuhur:\t\t %@",[dateFormatter stringFromDate:dhuhurTime]]];
	[asrItem setTitle:[NSString stringWithFormat:@"Asr:\t\t\t %@",[dateFormatter stringFromDate:asrTime]]];
	[maghribItem setTitle:[NSString stringWithFormat:@"Maghrib:\t %@",[dateFormatter stringFromDate:maghribTime]]];
	[ishaItem setTitle:[NSString stringWithFormat:@"Isha:\t\t %@",[dateFormatter stringFromDate:ishaTime]]];
	
	[dateFormatter release];
}





/*
 * check prayer time if seconds is 0 or if its been more than 60 seconds since the last check
 */
- (void) runLoop
{	
	
	if([[[NSCalendar currentCalendar] components:(NSSecondCalendarUnit) fromDate:[NSDate date]] second] == 0 || fabs([lastCheckTime timeIntervalSinceNow]) >= 60.0) {
		[lastCheckTime release];
		lastCheckTime = [[NSDate date] retain];
		
		[self checkPrayerStatus];
	}
}


- (void) checkPrayerStatus
{
	// if its a new day, recalculate and display the prayer times and check for updates
	if(currentDay != [[[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]] day]) {
		[self setPrayerTimes];
		[self displayPrayerTimes];
		if(checkForUpdates) [self checkForUpdate:YES];
	}
	
	// set menu bar title
	[self setMenuBarTitle];
	
	// set status icons
	[self setStatusIcons];
	
	// check prayer times for adhan
	[self checkPrayertimes];
}

- (void) setMenuBarTitle
{
	/* Set menu bar display */
	NSString *nextPrayerNameDisplay = @"";
	NSString *nextPrayerTimeDisplay = @"";
	
	if(displayIcon) {
		[menuBar setImage: [NSImage imageNamed: @"menuBar"]];
		[menuBar setAlternateImage:[NSImage imageNamed: @"menuBarHighlight"]];
	} else {
		[menuBar setImage: nil];
		[menuBar setAlternateImage: nil];
		
		displayNextPrayer = YES;
	}	
	
	if(displayNextPrayer) {
		
		if([fajrTime timeIntervalSinceNow] >= 0 || ([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60)) {
			
			if([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Fajr";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Fajr"];
				nextPrayerTimeDisplay = [self getTimeDisplay:fajrTime];
			}
			
		} else if([dhuhurTime timeIntervalSinceNow] >= 0 || ([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60)) {
			
			if([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Dhuhur";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Dhuhur"];
				nextPrayerTimeDisplay = [self getTimeDisplay:dhuhurTime];
			}
			
		} else if([asrTime timeIntervalSinceNow] >= 0 || ([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60)) {
			
			if([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Asr";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Asr"];
				nextPrayerTimeDisplay = [self getTimeDisplay:asrTime];
			}
			
		} else if([maghribTime timeIntervalSinceNow] >= 0 || ([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60)) {
			
			if([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Maghrib";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Maghrib"];
				nextPrayerTimeDisplay = [self getTimeDisplay:maghribTime];
			}
			
		} else if([ishaTime timeIntervalSinceNow] >= 0 || ([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60)) {
			
			if([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Isha";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Isha"];
				nextPrayerTimeDisplay = [self getTimeDisplay:ishaTime];
			}
			
		} else {
			
			nextPrayerNameDisplay = [self getNameDisplay:@"Fajr"];
			nextPrayerTimeDisplay = [self getTimeDisplay:tomorrowFajrTime];
		}
		
		[menuBar setTitle:[NSString stringWithFormat:@"%@ %@", nextPrayerNameDisplay, nextPrayerTimeDisplay]];
		
	} else {
		[menuBar setTitle:@""];
	}
}

- (NSString *) getNameDisplay:(NSString *)prayerName
{
	NSString *nameDisplay = @"";
	
	// get the name display option
	if(displayNextPrayerName == 0) {	
		// display whole name
		nameDisplay = prayerName;
	} else if(displayNextPrayerName == 1) {
		// display abbreviation
		nameDisplay = [prayerName substringToIndex:1];
	} else if(displayNextPrayerName == 2) {
		// display nothing
		nameDisplay = @"";
	}	
	
	return nameDisplay;
}

- (NSString *) getTimeDisplay:(NSDate *)prayerTime
{
	NSString *timeDisplay = @"";
	
	NSLog([prayerTime description]);
	
	// get the time display option
	if(displayNextPrayerTime == 0) {
		
		// display next prayer time
		timeDisplay = [prayerTime descriptionWithCalendarFormat:@"%1I:%M" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
		
	} else if(displayNextPrayerTime == 1) {
		
		// display amount of time left until the next prayer
		float hours = floor([prayerTime timeIntervalSinceNow]/3600);
		float minutes = ceil(([prayerTime timeIntervalSinceNow] - (hours * 3600)) / 60);
		timeDisplay = [NSString stringWithFormat:@"-%.0f:%02.0f",hours,minutes];
		
	} else if(displayNextPrayerTime == 2) {
		
		// display nothing
		timeDisplay = @"";
	}
	
	return timeDisplay;
}


- (void) setStatusIcons
{
	// default all status icons to not time
	[fajrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[shuruqItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[dhuhurItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[asrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[maghribItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[ishaItem setImage:[NSImage imageNamed:@"status_notTime"]];
	
	// check which prayer it is currently time for
	if([ishaTime timeIntervalSinceNow] <= 0) {

		[ishaItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		
	} else if([maghribTime timeIntervalSinceNow] <= 0) {
		
		[maghribItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		
	} else if([asrTime timeIntervalSinceNow] <= 0) {
		
		[asrItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		
	} else if([dhuhurTime timeIntervalSinceNow] <= 0) {
		
		[dhuhurItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		
	} else if([fajrTime timeIntervalSinceNow] <= 0) {
		
		if([shuruqTime timeIntervalSinceNow] > 0) {
			[fajrItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		}	
		
	}	else {
		
		[ishaItem setImage:[NSImage imageNamed:@"status_prayerTime"]];
		
	}
}



- (void) checkPrayertimes
{
	if([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60) {
		NSLog(@"time for fajr!");
	}
	
	if([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60) {
		NSLog(@"time for dhuhur!");
	}
	
	if([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60) {
		NSLog(@"time for asr!");
	}
	
	if([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60) {
		NSLog(@"time for maghrib!");
	}
	
	if([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60) {
		NSLog(@"time for isha!");
	}
	
}



/*
 * load all the values from the user preferences file into variables
 */
- (void) loadPreferences
{	
	// startup preferences
	firstRun = [userDefaults boolForKey:@"FirstRun"];	
	preferencesVersion = [userDefaults integerForKey:@"PreferencesVersion"];
	checkForUpdates = [userDefaults boolForKey:@"CheckForUpdates"];
	
	// general preferences
	displayIcon = [userDefaults boolForKey:@"DisplayIcon"];
	displayNextPrayer = [userDefaults boolForKey:@"DisplayNextPrayer"];
	displayNextPrayerName = [userDefaults integerForKey:@"DisplayNextPrayerName"];
	displayNextPrayerTime = [userDefaults integerForKey:@"DisplayNextPrayerTime"];
	
	// prayer time preferences
	latitude = [userDefaults floatForKey:@"Latitude"];
	longitude = [userDefaults floatForKey:@"Longitude"];
	systemTimezone = [userDefaults boolForKey:@"SystemTimezone"];
	timezone = [userDefaults floatForKey:@"Timezone"];
	daylightSavings = [userDefaults boolForKey:@"DaylightSavings"];
	madhab = [userDefaults integerForKey:@"Madhahb"];
	method = [userDefaults integerForKey:@"Method"];
	customSunriseAngle = [userDefaults floatForKey:@"CustomSunriseAngle"];
	customSunsetAngle = [userDefaults floatForKey:@"CustomSunsetAngle"];
	fajrOffset = [userDefaults integerForKey:@"FajrOffset"];
	shuruqOffset = [userDefaults integerForKey:@"ShuruqOffset"];
	dhuhurOffset = [userDefaults integerForKey:@"DhuhurOffset"];
	asrOffset = [userDefaults integerForKey:@"AsrOffset"];
	maghribOffset = [userDefaults integerForKey:@"MaghribOffset"];
	ishaOffset = [userDefaults integerForKey:@"IshaOffset"];
	
	// alert preferences
	enableSound = [userDefaults boolForKey:@"EnableSound"];
	soundFile = [userDefaults integerForKey:@"SoundFile"];
	userSound = [userDefaults boolForKey:@"UserSound"];
	userSoundFile = [userDefaults stringForKey:@"UserSoundFile"];
	playAdhanForFajr = [userDefaults boolForKey:@"PlayAdhanForFajr"];
	playAdhanForDhuhur = [userDefaults boolForKey:@"PlayAdhanForDhuhur"];
	playAdhanForAsr = [userDefaults boolForKey:@"PlayAdhanForAsr"];
	playAdhanForMaghrib = [userDefaults boolForKey:@"PlayAdhanForMaghrib"];
	playAdhanForIsha = [userDefaults boolForKey:@"PlayAdhanForIsha"];
	fajrReminder = [userDefaults boolForKey:@"FajrReminder"];
	minutesBeforeFajr = [userDefaults integerForKey:@"MinutesBeforeFajr"];
	shuruqReminder = [userDefaults boolForKey:@"ShuruqReminder"];
	minutesBeforeShuruq = [userDefaults integerForKey:@"MinutesBeforeShuruq"];
	enableGrowl = [userDefaults boolForKey:@"EnableGrowl"];
	stickyGrowl = [userDefaults boolForKey:@"StickyGrowl"];
}




/*
 * load user preferences into variables, caclulate and set prayer times, and recheck prayer times
 */
- (void) applyPrefs
{
	//reload preferences
	[self loadPreferences];
	
	//recalculate prayer times
	[self setPrayerTimes];
	
	//display prayer times
	[self displayPrayerTimes];
	
	//recheck prayer times
	[self checkPrayerStatus];
}







/****************/
/* USER ACTIONS */
/****************/

- (IBAction)stopAdhan:(id)sender 
{
	//[adhan stop];
}


- (IBAction)doNothing:(id)sender 
{
	//absolutely nothing
}


/*
 * opens about window and puts it in front of all windows and apps
 */
- (IBAction)openAboutPanel:(id)sender
{
	[[AboutController sharedAboutWindowController] showWindow:nil];
	[[[AboutController sharedAboutWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	[[AboutController sharedAboutWindowController] setVersionText:[self getVersion]];
	[[AboutController sharedAboutWindowController] setBuildNumber:[self getBuildNumber]];
}


/*
 * opens up help webpage 
 */
- (IBAction)getHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/help/"]];
}


/*
 * opens preferences window and puts it in front of all windows and apps
 */
- (IBAction)openPreferencesWindow:(id)sender
{	
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
}





/********************/
/* UPDATE FUNCTIONS */
/********************/

/*
 * checks for new version based on the build number
 */
- (void) checkForUpdate:(BOOL)quiet
{
	int currentBuild = [self getBuildNumber];
	
	NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://guidanceapp.com/version.xml"]];
	int latestBuild = [[productVersionDict valueForKey:@"build"] intValue];
	NSString *latestVersionNumber = [productVersionDict valueForKey:@"version"];
    
	if([productVersionDict count] > 0 ) 
	{
		if(currentBuild >= latestBuild && !quiet)
		{
			// tell user software is up to date
			[NSApp activateIgnoringOtherApps:YES];
			NSRunAlertPanel(NSLocalizedString(@"Your Software is up to date", @"Title of alert when a the user's software is up to date."),
							NSLocalizedString(@"You have the most recent version of Guidance.", @"Alert text when the user's software is up to date."),
							NSLocalizedString(@"OK", @"OK"), nil, nil);
		}
		else if(currentBuild < latestBuild)
		{
			// tell user to download a new version
			[NSApp activateIgnoringOtherApps:YES];
			int button = NSRunAlertPanel(NSLocalizedString(@"A New Version is Available", @"Title of alert when a the user's software is not up to date."),
										 [NSString stringWithFormat:NSLocalizedString(@"A new version of Guidance is available (version %@ r%i). Would you like to download the new version now?", @"Alert text when the user's software is not up to date."), latestVersionNumber,latestBuild],
										 NSLocalizedString(@"OK", @"OK"),
										 NSLocalizedString(@"Cancel", @"Cancel"), nil);
			if(NSOKButton == button)
			{
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/download/"]];
			}
		}
	} else if(!quiet) {
		// tell user unable to check for update
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(NSLocalizedString(@"Unable to check for updates", @"Title of alert"),
						NSLocalizedString(@"Guidance is currently unable to check for updates.", @"Alert text"),
						NSLocalizedString(@"OK", @"OK"), nil, nil);
	}
}


/*
 * returns the version listed in CFBundleShortVersionString from Info.plist
 */
- (NSString *) getVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	
}


/*
 * returns the version listed in CFBundleVersion from Info.plist as an integer
 */
- (int) getBuildNumber
{
	NSString *buildString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	return [buildString intValue];
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



/*************************************
********** GROWL METHODS *************
*************************************/

/*
 * initialize growl and set the delegate as self
 */
- (id) init
{
	if ((self = [super init]))
	{
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	
	return self;
}


/*
 * register growl dictionary
 */
- (NSDictionary *) registrationDictionaryForGrowl
{
		NSArray *notifications = [NSArray arrayWithObjects: NotificationName, nil];

		NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Guidance", GROWL_APP_NAME,
				notifications, GROWL_NOTIFICATIONS_ALL,
				notifications, GROWL_NOTIFICATIONS_DEFAULT,
				nil];

	return regDict;
}


/*
 * creates and displays a growl notification
 * @input String with the title of the notification
 * @input String with the description of the notification
 * @input boolean sticky status is true for sticky and false for normal
 * @input object context to pass back to the delegate when clicked
 * @input String optional identifying string is null for most cases
 */
- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky : (id) clickContext : (NSString *)identifier
{ 
	[GrowlApplicationBridge notifyWithTitle:title
					description:desc
					notificationName:NotificationName
					iconData: nil
					priority:0
					isSticky:sticky
					clickContext:clickContext
					identifier:identifier];
}


/*
 * called when a user clicks on a growl notification
 */
- (void) growlNotificationWasClicked:(id)clickContext 
{
	//[self stopAdhan:nil];
}


/*
 * returns a boolean value indicating 
 * whether or not growl is installed
 * @return boolean yes if growl is installed or no if growl is not installed
 */ 
- (BOOL) isGrowlInstalled 
{
  return [GrowlApplicationBridge isGrowlInstalled];
}



@end


