//
//  AboutController.m
//  Guidance
//
//  Created by Matthew Crenshaw on 11/8/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "AboutController.h"

static AboutController *_sharedAboutWindowController = nil;

@implementation AboutController

+ (AboutController *)sharedAboutWindowController
{
	if (!_sharedAboutWindowController) {
		_sharedAboutWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedAboutWindowController;
}

+ (NSString *)nibName
{
   return @"About";
}

- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self) {
		toggleCredits = NO;
	}
	
	return self;
	(void)window;
}

- (void)windowDidLoad
{
	[creditsBox setHidden:YES];
}

- (void)setVersionText:(NSString *)version buildNumber:(int)number
{
	[guidanceVersion setStringValue:[NSString stringWithFormat:@"Version %@ (%i)",version,number]];
}


- (IBAction)toggleCredits:(NSButton *)sender
{
	toggleCredits = !toggleCredits;
	
	if (toggleCredits)
	{
		[creditsBox setHidden:NO];
	}
	else
	{
		[creditsBox setHidden:YES];
	}
}

- (IBAction)goDonate:(NSButton *)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://guidanceapp.com/donate/"]]; //go to the donate page
}

@end
