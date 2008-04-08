//
//  WelcomeController.h
//  Guidance
//
//  Created by Ameir Al-Zoubi on 2/13/08.
//  Copyright 2008 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WelcomeController : NSWindowController {
	
	IBOutlet NSButton *myButton;
	IBOutlet NSTextField *welcomeMsg;
}

+ (WelcomeController *)sharedWelcomeWindowController;
+ (NSString *)nibName;


- (IBAction)goDonate:(NSButton *)sender;

@end
