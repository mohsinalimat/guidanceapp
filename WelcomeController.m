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


- (IBAction)goDonate:(NSButton *)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/donate/"]]; //go to the donate page
	[welcomeMsg setStringValue:@"thanks!"];
}


@end






