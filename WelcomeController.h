//
//  WelcomeController.h
//  Guidance
//
//  Created by Ameir Al-Zoubi on 2/13/08.
//  Copyright 2008 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "PrefController.h"

@interface WelcomeController : NSWindowController {
	
	IBOutlet NSTextField *location;
	IBOutlet NSTextField *lookupStatus;
	IBOutlet NSProgressIndicator *lookupIndicator;
	IBOutlet NSWindow *welcomeWindow;
	IBOutlet NSButton *startAtLogin;
	
	NSUserDefaults *userDefaults;
}

+ (WelcomeController *)sharedWelcomeWindowController;
+ (NSString *)nibName;

- (IBAction)done:(id)sender;
- (IBAction)lookup:(id)sender;
- (IBAction)startAtLogin:(id)sender;
- (BOOL)startsAtLogin;
- (BOOL)locationLookup;

@end
