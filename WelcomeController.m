//
//  WelcomeController.m
//  Guidance
//
//  Created by Ameir Al-Zoubi on 2/13/08.
//  Copyright 2008 Batoul Apps. All rights reserved.
//

#import "WelcomeController.h"

static WelcomeController *_sharedWelcomeWindowController = nil;


@implementation WelcomeController

+ (WelcomeController *)sharedWelcomeWindowController
{
	if (!_sharedWelcomeWindowController) {
		_sharedWelcomeWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedWelcomeWindowController;
}

+ (NSString *)nibName
{
   return @"Welcome";
}

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[userDefaults registerDefaults:appDefaults];
	
	[lookupStatus setStringValue:@""];
	[lookupIndicator setDisplayedWhenStopped:NO];

	if([self startsAtLogin]) {
		[startAtLogin setState:1];
		[userDefaults setBool:YES forKey:@"StartAtLogin"];
	} else {
		[startAtLogin setState:0];
		[userDefaults setBool:NO forKey:@"StartAtLogin"];
	}
}

- (IBAction)done:(id)sender
{
	BOOL valid = [self locationLookup];
	
	//write user preferences to pref file
	[userDefaults synchronize];
	
	//tell appcontroller to check and apply prefs
	[[AppController sharedController] applyPrefs];
	
	//close window
	[welcomeWindow close];
	
	if(!valid) {
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(NSLocalizedString(@"Unable to find location", @"Title of alert telling user that their location was not found."),
						NSLocalizedString(@"Guidance was unable to find the location you entered, please enter a different location in the preferences.", @"Alert text when the user's location was not found."),
						NSLocalizedString(@"OK", @"OK"), nil, nil);
		
	}
}

- (BOOL)locationLookup {
	[lookupIndicator setDisplayedWhenStopped:YES];
	[lookupIndicator startAnimation:self];	
	[lookupStatus setStringValue:@"Looking up latitude and longitude..."];
	[welcomeWindow display];
	
	NSString *userLocation = [location stringValue];
	
	NSString *urlSafeUserLocation =[(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) userLocation, NULL, NULL, kCFStringEncodingUTF8) autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://guidanceapp.com/location.php?loc=%@",urlSafeUserLocation];
	NSDictionary *coordDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:urlString]];
	
	BOOL valid = (BOOL) [[coordDict valueForKey:@"valid"] intValue];
	
	if(coordDict == nil) {
		[lookupStatus setStringValue:@"Error: Unable reach server"];
		[lookupStatus setTextColor:[NSColor redColor]];
		[lookupIndicator stopAnimation:self];
		
		valid = NO;
	} else {
		if (valid)
		{
			[userDefaults setFloat:[[coordDict valueForKey:@"latitude"] doubleValue] forKey:@"Latitude"];
			[userDefaults setFloat:[[coordDict valueForKey:@"longitude"] doubleValue] forKey:@"Longitude"];
			[userDefaults setValue:[location stringValue] forKey:@"Location"];	
			
			[lookupStatus setStringValue:@"Your location has been set"];
			[lookupStatus setTextColor:[NSColor blackColor]];
			[lookupIndicator stopAnimation:self];
		}
		else
		{
			[lookupStatus setStringValue:@"Error: Unable to find location"];
			[lookupStatus setTextColor:[NSColor redColor]];
			[lookupIndicator stopAnimation:self];
		}
	}
	
	return valid;
}


- (IBAction)lookup:(id)sender {
	[self locationLookup];
}

- (IBAction)startAtLogin:(id)sender
{
	int i = 0;
	NSMutableArray* loginItems;
	
    loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    loginItems =  [[loginItems autorelease] mutableCopy];
	
	NSMutableDictionary *loginObject = [[NSMutableDictionary alloc] initWithCapacity:2];
	
	if([startAtLogin state] == NSOnState) {
		
		//add it to login items
		[loginObject setObject:[[NSBundle mainBundle] bundlePath] forKey:@"Path"];
		[loginItems addObject:loginObject];
		
	} else {
		
		//remove it from login items
		for (i=0;i<[loginItems count];i++)
        {
            if ([[[loginItems objectAtIndex:i] objectForKey:@"Path"] isEqualToString:[[NSBundle mainBundle] bundlePath]])
                [loginItems removeObjectAtIndex:i];
        }
	}
	
    CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems, (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 
	CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	
    [loginItems release];	
}


- (BOOL)startsAtLogin
{
	BOOL starts = NO;
	int i = 0;
	NSMutableArray* loginItems;
	
    loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef) @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    loginItems =  [[loginItems autorelease] mutableCopy];
	
	
	for (i=0;i<[loginItems count];i++)
	{
		if ([[[loginItems objectAtIndex:i] objectForKey:@"Path"] isEqualToString:[[NSBundle mainBundle] bundlePath]]) {
			starts = YES;
		}
	}
	
    [loginItems release];
	return starts;
}


@end






