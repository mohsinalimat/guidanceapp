//
//  AboutController.h
//  Guidance
//
//  Created by Matthew Crenshaw on 11/8/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutController : NSWindowController {
	BOOL toggleCredits;
	
	IBOutlet NSScrollView *creditsBox;
	IBOutlet NSTextField *guidanceVersion;
}

+ (AboutController *)sharedAboutWindowController;
+ (NSString *)nibName;

- (IBAction)goDonate:(NSButton *)sender;

- (IBAction)toggleCredits:(NSButton *)sender;

- (void)setVersionText:(NSString *)version buildNumber:(int)number;

@end
