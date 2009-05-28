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
	
	menuBarAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
	    [NSColor redColor], NSForegroundColorAttributeName,
	    [NSFont menuBarFontOfSize:0.0], NSFontAttributeName,
	    nil];
	
	islamicCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSIslamicCalendar];

	[self createAppMenu];
	
	[self loadPreferences];
	
	todaysPrayerTimes = [[PrayerTimes alloc] init];
	tomorrowsPrayerTimes = [[PrayerTimes alloc] init];
	[self setPrayerTimes];
	
	[self displayPrayerTimes];
	
	lastAdhanAlert = [[NSDate dateWithTimeIntervalSinceNow:-1] retain];
	lastGrowlAlert = [[NSDate dateWithTimeIntervalSinceNow:-1] retain];

	adhanIsPlaying = NO;
	currentAdhan = 0;
	adhanList = [NSArray arrayWithObjects:@"yusufislam", @"makkah", @"alaqsa", @"istanbul", @"fajr", nil];
	[adhanList retain];
	
	//set up adhan qtmovie object
	adhan = [[QTMovie alloc] init];
	[adhan setDelegate:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundDidEnd:) name:QTMovieDidEndNotification object:adhan];
	
	[self checkPrayerStatus];
	
	//running loop that checks prayer times every second
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runLoop) userInfo:nil repeats:YES]; 
	
	
	//check if growl is installed
	if(![self isGrowlInstalled]) {
		[self doGrowl : @"Guidance" : @"Request Growl installation" : NO : nil : nil];
	}
	
	//check for new version
	[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
	
	// bring  up welcome window if this is the first time the program has been ran 
	// or if the preferences are incompatible
	if(firstRun) {
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
	
	muteAdhan = [[NSMenuItem alloc] initWithTitle:@"Mute Adhan" action:@selector(stopAdhan) keyEquivalent:@""];
	
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
	currentTimezone = ((float)[[NSTimeZone systemTimeZone] secondsFromGMT])/3600;
	
	fajrTime = [[todaysPrayerTimes getFajrTime] retain];
	shuruqTime = [[todaysPrayerTimes getShuruqTime] retain];
	dhuhurTime = [[todaysPrayerTimes getDhuhurTime] retain];
	asrTime = [[todaysPrayerTimes getAsrTime] retain];
	maghribTime = [[todaysPrayerTimes getMaghribTime] retain];
	ishaTime = [[todaysPrayerTimes getIshaTime] retain];
	
	tomorrowFajrTime = [[tomorrowsPrayerTimes getFajrTime] retain];
	
	fajrReminderTime = [[[NSDate alloc] initWithTimeInterval:minutesBeforeFajr*-60 sinceDate:fajrTime] retain];
	shuruqReminderTime = [[[NSDate alloc] initWithTimeInterval:minutesBeforeShuruq*-60 sinceDate:shuruqTime] retain];

}


- (void) displayPrayerTimes 
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	if ([self clockShows24Hr])
		[dateFormatter setDateFormat:@"HH:mm"];
	else {
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	
	[hijriItem setTitle:[self hijriDate]];
	[fajrItem setTitle:[NSString stringWithFormat:@"Fajr:\t\t %@",[dateFormatter stringFromDate:fajrTime]]];
	[shuruqItem setTitle:[NSString stringWithFormat:@"Shuruq:\t\t %@",[dateFormatter stringFromDate:shuruqTime]]];
	[dhuhurItem setTitle:[NSString stringWithFormat:@"Dhuhur:\t\t %@",[dateFormatter stringFromDate:dhuhurTime]]];
	[asrItem setTitle:[NSString stringWithFormat:@"Asr:\t\t\t %@",[dateFormatter stringFromDate:asrTime]]];
	[maghribItem setTitle:[NSString stringWithFormat:@"Maghrib:\t %@",[dateFormatter stringFromDate:maghribTime]]];
	[ishaItem setTitle:[NSString stringWithFormat:@"Isha:\t\t %@",[dateFormatter stringFromDate:ishaTime]]];
	
	[dateFormatter release];
}


/*
 * return true if the system clock is using a 24 hour format
 */
- (BOOL) clockShows24Hr
{
	CFStringRef clockID = CFSTR("com.apple.MenuBarClock");
	CFStringRef use24HourClock = CFSTR("Use24HourClock");
	
	Boolean hasKey;
	BOOL result = CFPreferencesGetAppBooleanValue(use24HourClock, clockID, &hasKey);
	return (hasKey && result);
}


/*
 * check prayer time every second
 */
- (void) runLoop
{		
	[self checkPrayerStatus];
}


- (void) checkPrayerStatus
{
	// if its a new day or dst has changed, recalculate and display the prayer times and check for updates
	if(currentDay != [[[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]] day] ||
	   currentTimezone != ((float)[[NSTimeZone systemTimeZone] secondsFromGMT])/3600) {
		[self setPrayerTimes];
		[self displayPrayerTimes];
		if([[SUUpdater sharedUpdater] automaticallyChecksForUpdates]) {
			[[SUUpdater sharedUpdater] checkForUpdatesInBackground];
		}
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
		
		BOOL startingSoon = NO;
		const double soonEnough = 30.0 * 60.0;  // 30 minutes
		if([fajrTime timeIntervalSinceNow] >= 0 || ([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60)) {
			
 			if([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Fajr";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Fajr"];
				nextPrayerTimeDisplay = [self getTimeDisplay:fajrTime];
				startingSoon = [fajrTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else if([shuruqTime timeIntervalSinceNow] >= 0 || ([shuruqTime timeIntervalSinceNow] <= 0 && [shuruqTime timeIntervalSinceNow] > -60)) {
			
			if([shuruqTime timeIntervalSinceNow] <= 0 && [shuruqTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Shuruq";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Shuruq"];
				nextPrayerTimeDisplay = [self getTimeDisplay:shuruqTime];
				startingSoon = [shuruqTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else if([dhuhurTime timeIntervalSinceNow] >= 0 || ([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60)) {
			
			if([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Dhuhur";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Dhuhur"];
				nextPrayerTimeDisplay = [self getTimeDisplay:dhuhurTime];
				startingSoon = [dhuhurTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else if([asrTime timeIntervalSinceNow] >= 0 || ([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60)) {
			
			if([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Asr";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Asr"];
				nextPrayerTimeDisplay = [self getTimeDisplay:asrTime];
				startingSoon = [asrTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else if([maghribTime timeIntervalSinceNow] >= 0 || ([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60)) {
			
			if([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Maghrib";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Maghrib"];
				nextPrayerTimeDisplay = [self getTimeDisplay:maghribTime];
				startingSoon = [maghribTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else if([ishaTime timeIntervalSinceNow] >= 0 || ([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60)) {
			
			if([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60) {
				nextPrayerNameDisplay = @"Isha";
				nextPrayerTimeDisplay = @"Time";
			} else {
				
				nextPrayerNameDisplay = [self getNameDisplay:@"Isha"];
				nextPrayerTimeDisplay = [self getTimeDisplay:ishaTime];
				startingSoon = [ishaTime timeIntervalSinceNow] <= soonEnough;
			}
			
		} else {
			
			nextPrayerNameDisplay = [self getNameDisplay:@"Fajr"];
			nextPrayerTimeDisplay = [self getTimeDisplay:tomorrowFajrTime];
			startingSoon = [tomorrowFajrTime timeIntervalSinceNow] <= soonEnough;
		}
		
		NSString *title = [NSString stringWithFormat:@"%@ %@", nextPrayerNameDisplay, nextPrayerTimeDisplay];
		if (startingSoon) {
			NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:menuBarAttributes];
			[menuBar setAttributedTitle:attributedTitle];
			[attributedTitle release];			
		} else {
			[menuBar setTitle:title];
		}
		
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
	
	// get the time display option
	if(displayNextPrayerTime == 0) {
		
		// display next prayer time
		timeDisplay = [prayerTime descriptionWithCalendarFormat:@"%1I:%M" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
		
	} else if(displayNextPrayerTime == 1) {
		
		// display amount of time left until the next prayer
		int hours = floor([prayerTime timeIntervalSinceNow]/3600);
		int minutes = ceil(([prayerTime timeIntervalSinceNow] - (hours * 3600)) / 60);
		
		if(minutes >= 60) {
			int additionalHours = floor(minutes / 60);	
			hours += additionalHours;
			minutes -= additionalHours * 60;
		}
		
		
		timeDisplay = [NSString stringWithFormat:@"-%i:%02i",hours,minutes];
		
	} else if(displayNextPrayerTime == 2) {
		
		// display nothing
		timeDisplay = @"";
	}
	
	return timeDisplay;
}


- (void) setStatusIcons
{
	// default all status icons to not time and their actions to do nothing
	[fajrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[fajrItem setAction:@selector(doNothing:)];
	
	[shuruqItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[shuruqItem setAction:@selector(doNothing:)];
	
	[dhuhurItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[dhuhurItem setAction:@selector(doNothing:)];
	
	[asrItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[asrItem setAction:@selector(doNothing:)];
	
	[maghribItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[maghribItem setAction:@selector(doNothing:)];
	
	[ishaItem setImage:[NSImage imageNamed:@"status_notTime"]];
	[ishaItem setAction:@selector(doNothing:)];
	
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
	
	
	if(currentAdhan == 1) {
		[fajrItem setImage:[NSImage imageNamed:@"status_sound"]];
		[fajrItem setAction:@selector(stopAdhan)];
	} else if(currentAdhan == 2) {
		[dhuhurItem setImage:[NSImage imageNamed:@"status_sound"]];
		[dhuhurItem setAction:@selector(stopAdhan)];
		
	} else if(currentAdhan == 3) {
		[asrItem setImage:[NSImage imageNamed:@"status_sound"]];
		[asrItem setAction:@selector(stopAdhan)];
		
	} else if(currentAdhan == 4) {
		[maghribItem setImage:[NSImage imageNamed:@"status_sound"]];
		[maghribItem setAction:@selector(stopAdhan)];
			
	} else if(currentAdhan == 5) {
		[ishaItem setImage:[NSImage imageNamed:@"status_sound"]];
		[ishaItem setAction:@selector(stopAdhan)];
		
	}
}



- (void) checkPrayertimes
{
	if([fajrTime timeIntervalSinceNow] <= 0 && [fajrTime timeIntervalSinceNow] > -60) {
		
		if(enableGrowl && ![fajrTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = fajrTime;
			
			[self doGrowl :@"Fajr" 
						  :[NSString stringWithFormat:@"%@\nIt's time to pray Fajr",[fajrTime descriptionWithCalendarFormat:@"%1I:%M %p" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] 
						  :stickyGrowl 
						  :@"" 
						  :@"Fajr"];	
		} 
		
		if(!silentMode && fajrAdhanOption != 0 && ![fajrTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = fajrTime;
			userSound = fajrAdhanUserSound;
			userSoundFile = fajrAdhanUserSoundFile;
			adhanOption = fajrAdhanOption;
			[self playAdhan:1];
		}
	}
	
	if([dhuhurTime timeIntervalSinceNow] <= 0 && [dhuhurTime timeIntervalSinceNow] > -60) {
	
		if(enableGrowl && ![dhuhurTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = dhuhurTime;
			
			[self doGrowl :@"Dhuhur" 
						  :[NSString stringWithFormat:@"%@\nIt's time to pray Dhuhur",[dhuhurTime descriptionWithCalendarFormat:@"%1I:%M %p" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] 
						  :stickyGrowl 
						  :@"" 
						  :@"Dhuhur"];	
		} 
		
		if(!silentMode && dhuhurAdhanOption != 0 && ![dhuhurTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = dhuhurTime;
			userSound = dhuhurAdhanUserSound;
			userSoundFile = dhuhurAdhanUserSoundFile;
			adhanOption = dhuhurAdhanOption;
			[self playAdhan:2];
		}
	}
	
	if([asrTime timeIntervalSinceNow] <= 0 && [asrTime timeIntervalSinceNow] > -60) {
	
		if(enableGrowl && ![asrTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = asrTime;
			
			[self doGrowl :@"Asr" 
						  :[NSString stringWithFormat:@"%@\nIt's time to pray Asr",[asrTime descriptionWithCalendarFormat:@"%1I:%M %p" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] 
						  :stickyGrowl 
						  :@"" 
						  :@"Asr"];	
		} 
		
		if(!silentMode && asrAdhanOption != 0 && ![asrTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = asrTime;
			userSound = asrAdhanUserSound;
			userSoundFile = asrAdhanUserSoundFile;
			adhanOption = asrAdhanOption;
			[self playAdhan:3];
		}
	}
	
	if([maghribTime timeIntervalSinceNow] <= 0 && [maghribTime timeIntervalSinceNow] > -60) {
		
		if(enableGrowl && ![maghribTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = maghribTime;
			
			[self doGrowl :@"Maghrib" 
						  :[NSString stringWithFormat:@"%@\nIt's time to pray Maghrib",[maghribTime descriptionWithCalendarFormat:@"%1I:%M %p" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] 
						  :stickyGrowl 
						  :@"" 
						  :@"Maghrib"];	
		} 
		
		if(!silentMode && maghribAdhanOption != 0 && ![maghribTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = maghribTime;
			userSound = maghribAdhanUserSound;
			userSoundFile = maghribAdhanUserSoundFile;
			adhanOption = maghribAdhanOption;
			[self playAdhan:4];
		}
	}
	
	if([ishaTime timeIntervalSinceNow] <= 0 && [ishaTime timeIntervalSinceNow] > -60) {
		
		if(enableGrowl && ![ishaTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = ishaTime;
			
			[self doGrowl :@"Isha" 
						  :[NSString stringWithFormat:@"%@\nIt's time to pray Isha",[ishaTime descriptionWithCalendarFormat:@"%1I:%M %p" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]] 
						  :stickyGrowl 
						  :@"" 
						  :@"Isha"];	
		} 
		
		if(!silentMode && ishaAdhanOption != 0 && ![ishaTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = ishaTime;
			userSound = ishaAdhanUserSound;
			userSoundFile = ishaAdhanUserSoundFile;
			adhanOption = ishaAdhanOption;
			[self playAdhan:5];
		}
	}
	
	if(fajrReminder && [fajrReminderTime timeIntervalSinceNow] <= 0 && [fajrReminderTime timeIntervalSinceNow] > -60) {
		
		if(enableGrowl && ![fajrReminderTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = fajrReminderTime;
			
			[self doGrowl :@"Fajr Reminder" 
						  :[NSString stringWithFormat:@"Fajr is in %i minutes",minutesBeforeFajr] 
						  :stickyGrowl 
						  :@"" 
						  :@"Fajr Reminder"];	
		} 
		
		if(!silentMode && fajrReminderAdhanOption != 0 && ![fajrReminderTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = fajrReminderTime;
			userSound = fajrReminderAdhanUserSound;
			userSoundFile = fajrReminderAdhanUserSoundFile;
			adhanOption = fajrReminderAdhanOption;
			[self playAdhan:0];
		}	
		
	}
	
	if(shuruqReminder && [shuruqReminderTime timeIntervalSinceNow] <= 0 && [shuruqReminderTime timeIntervalSinceNow] > -60) {
		
		if(enableGrowl && ![shuruqReminderTime isEqualToDate:lastGrowlAlert]) {
			
			lastGrowlAlert = shuruqReminderTime;
			
			[self doGrowl :@"Shuruq Reminder" 
						  :[NSString stringWithFormat:@"Shuruq is in %i minutes",minutesBeforeShuruq] 
						  :stickyGrowl 
						  :@"" 
						  :@"Shuruq Reminder"];	
		} 
		
		if(!silentMode && shuruqReminderAdhanOption != 0 && ![shuruqReminderTime isEqualToDate:lastAdhanAlert]) {
			lastAdhanAlert = shuruqReminderTime;
			userSound = shuruqReminderAdhanUserSound;
			userSoundFile = shuruqReminderAdhanUserSoundFile;
			adhanOption = shuruqReminderAdhanOption;
			[self playAdhan:0];
		}	
		
	}
	
	
}


- (void) playAdhan:(int)prayerIndex 
{
	if(![self isAdhanPlaying]) {
		
		//if somehow an invalid index is passed in then default to adhan at index 2
		//or if an invalid custom file is passed then play adhan at index 2
		if( ((adhanOption < 2 || adhanOption > 6) && !userSound) || (userSound && ![[NSFileManager defaultManager] fileExistsAtPath:userSoundFile]) ) {
			userSound = NO;
			adhanOption = 2;
		}	
		
		
		if(pauseItunesPref) {
			[self pauseItunes];
		}
		
		adhanIsPlaying = YES;
		currentAdhan = prayerIndex;
		[self setStatusIcons];
		
		
		if(userSound) {
			adhanFile = [NSURL fileURLWithPath:userSoundFile];
		} else {
			adhanFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[adhanList objectAtIndex:adhanOption -2] ofType:@"mp3"]];
		}	
		
		[adhan initWithURL:adhanFile error:nil];
		[adhan setVolume:adhanVolume];
		[adhan play];
		
		//add mute adhan menu item 
		[appMenu insertItem:muteAdhan atIndex:0];
		[muteAdhan setTarget:self];
		[muteAdhan setAction:@selector(stopAdhan)];
		
		//add seperator
		[appMenu insertItem:[NSMenuItem separatorItem] atIndex:1];	
		
	}
}


- (BOOL) isAdhanPlaying
{
	return adhanIsPlaying;
}

- (void) stopAdhan
{
	[adhan stop];
	[self soundDidEnd:nil];
}


/*
 * sets currentlyPlayingAdhan to blank, removes sound icon, 
 * and removes mute adhan button and sets prayer items action to nothing
 */
- (void)soundDidEnd:(id)aNotification
{
	adhanIsPlaying = NO;
	currentAdhan = 0;
	[self setStatusIcons];
	
	//remove "Mute Adhan" option
	if([appMenu indexOfItem:muteAdhan] > -1) {
		[appMenu removeItemAtIndex:[appMenu indexOfItem:muteAdhan]];
	}

	if([appMenu indexOfItem:hijriItem] != 0) [appMenu removeItemAtIndex:0];
}


/*
 * pause itunes if its currently running and playing music
 */
- (void) pauseItunes 
{
	NSURL *scriptURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pauseItunes" ofType:@"scpt"]];
	NSDictionary *errors = [NSDictionary dictionary];
	
	NSAppleScript *pauseItunesScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&errors];
	
	[pauseItunesScript executeAndReturnError:&errors];

	[pauseItunesScript release];
}


/*
 * load all the values from the user preferences file into variables
 */
- (void) loadPreferences
{	
	// startup preferences
	firstRun = [userDefaults boolForKey:@"FirstRun"];	
	preferencesVersion = [userDefaults integerForKey:@"PreferencesVersion"];
	
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
	madhab = [userDefaults integerForKey:@"Madhab"];
	method = [userDefaults integerForKey:@"Method"];
	customSunriseAngle = [userDefaults floatForKey:@"CustomSunriseAngle"];
	customSunsetAngle = [userDefaults floatForKey:@"CustomSunsetAngle"];
	fajrOffset = [userDefaults integerForKey:@"FajrOffset"];
	shuruqOffset = [userDefaults integerForKey:@"ShuruqOffset"];
	dhuhurOffset = [userDefaults integerForKey:@"DhuhurOffset"];
	asrOffset = [userDefaults integerForKey:@"AsrOffset"];
	maghribOffset = [userDefaults integerForKey:@"MaghribOffset"];
	ishaOffset = [userDefaults integerForKey:@"IshaOffset"];
	hijriOffset = [userDefaults integerForKey:@"HijriOffset"];
	
	// alert preferences
	silentMode = [userDefaults boolForKey:@"EnableSilentMode"];
	
	//fajr alert options
	fajrAdhanOption = [userDefaults integerForKey:@"FajrAdhanOption"];
	fajrAdhanUserSound = [userDefaults boolForKey:@"FajrAdhanUserSound"];
	fajrAdhanUserSoundFile = [userDefaults stringForKey:@"FajrAdhanUserSoundFile"];
	
	//dhuhur alert options
	dhuhurAdhanOption = [userDefaults integerForKey:@"DhuhurAdhanOption"];
	dhuhurAdhanUserSound = [userDefaults boolForKey:@"DhuhurAdhanUserSound"];
	dhuhurAdhanUserSoundFile = [userDefaults stringForKey:@"DhuhurAdhanUserSoundFile"];
	
	//asr alert options
	asrAdhanOption = [userDefaults integerForKey:@"AsrAdhanOption"];
	asrAdhanUserSound = [userDefaults boolForKey:@"AsrAdhanUserSound"];
	asrAdhanUserSoundFile = [userDefaults stringForKey:@"AsrAdhanUserSoundFile"];
	
	//maghrib alert options
	maghribAdhanOption = [userDefaults integerForKey:@"MaghribAdhanOption"];
	maghribAdhanUserSound = [userDefaults boolForKey:@"MaghribAdhanUserSound"];
	maghribAdhanUserSoundFile = [userDefaults stringForKey:@"MaghribAdhanUserSoundFile"];
	
	//isha alert options
	ishaAdhanOption = [userDefaults integerForKey:@"IshaAdhanOption"];
	ishaAdhanUserSound = [userDefaults boolForKey:@"IshaAdhanUserSound"];
	ishaAdhanUserSoundFile = [userDefaults stringForKey:@"IshaAdhanUserSoundFile"];
	
	adhanVolume = [userDefaults floatForKey:@"AdhanVolume"];
	// update sound directly
	if ([self isAdhanPlaying])
		[adhan setVolume:adhanVolume];

	//shuruq reminder alert options
	shuruqReminderAdhanOption = [userDefaults integerForKey:@"ShuruqReminderAdhanOption"];
	shuruqReminderAdhanUserSound = [userDefaults boolForKey:@"ShuruqReminderAdhanUserSound"];
	shuruqReminderAdhanUserSoundFile = [userDefaults stringForKey:@"ShuruqReminderAdhanUserSoundFile"];
	
	//fajr reminder alert options
	fajrReminderAdhanOption = [userDefaults integerForKey:@"FajrReminderAdhanOption"];
	fajrReminderAdhanUserSound = [userDefaults boolForKey:@"FajrReminderAdhanUserSound"];
	fajrReminderAdhanUserSoundFile = [userDefaults stringForKey:@"FajrReminderAdhanUserSoundFile"];
	
	fajrReminder = [userDefaults boolForKey:@"FajrReminder"];
	minutesBeforeFajr = [userDefaults integerForKey:@"MinutesBeforeFajr"];
	
	shuruqReminder = [userDefaults boolForKey:@"ShuruqReminder"];
	minutesBeforeShuruq = [userDefaults integerForKey:@"MinutesBeforeShuruq"];
	
	pauseItunesPref = [userDefaults boolForKey:@"PauseItunes"];
	
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
 * opens preferences window and puts it in front of all windows and apps
 */
- (IBAction)openPreferencesWindow:(id)sender
{	
	[[PrefController sharedPrefsWindowController] showWindow:nil];
	[[[PrefController sharedPrefsWindowController] window] makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
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
	[self stopAdhan];
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


/*
 * modify the hijri date based off the manual adjustment set in preferences and then
 * returned a formatted string representation of the hijri date using NSDateFormatter
 */
- (NSString *) hijriDate
{
	NSTimeInterval hijriOffsetInSeconds = (hijriOffset - 3) * 60 * 60 * 24.0;

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setCalendar:islamicCalendar];

	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:hijriOffsetInSeconds];
	NSString *hijriDateString = [dateFormatter stringFromDate:date];
	
	[dateFormatter release];
	
	return hijriDateString;
}

@end


