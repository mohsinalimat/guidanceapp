//
//  WelcomeController.h
//  Guidance
//
//  Created by Ameir Al-Zoubi on 2/13/08.
//  Copyright 2008 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WelcomeController : NSWindowController {
	
	IBOutlet NSTextField *locationLookupMessage;
	IBOutlet NSProgressIndicator *locationLookupIndicator;
	IBOutlet NSWindow *welcomeWindow;
}

+ (WelcomeController *)sharedWelcomeWindowController;
+ (NSString *)nibName;


- (IBAction)done:(id)sender;
- (IBAction)lookup:(id)sender;
- (IBAction)startAtLogin:(id)sender;

@end
