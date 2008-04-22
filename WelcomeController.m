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
	[locationLookupMessage setStringValue:@""];
	[locationLookupIndicator setDisplayedWhenStopped:NO];
}

- (IBAction)done:(id)sender
{
	//save and apply prefs
	[welcomeWindow close];
}


- (IBAction)lookup:(id)sender
{
	[locationLookupMessage setStringValue:@"Looking up latitude and longitude..."];
	[locationLookupIndicator startAnimation:sender];	
}

- (IBAction)startAtLogin:(id)sender
{
	NSLog(@"Yo, start this thing at login!");
}


@end






