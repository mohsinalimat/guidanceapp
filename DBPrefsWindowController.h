//
//  DBPrefsWindowController.h
//  Guidance
//
//  Created by ameir on 10/21/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DBPrefsWindowController : NSWindowController {
	BOOL _crossFade;
	BOOL _shiftSlowsAnimation;
	
	NSMutableArray *toolbarIdentifiers;
	NSMutableDictionary *toolbarViews;
	NSMutableDictionary *toolbarItems;
	
	NSView *contentSubview;
	NSViewAnimation *viewAnimation;
}


+ (DBPrefsWindowController *)sharedPrefsWindowController;
+ (NSString *)nibName;

- (void)setupToolbar;
- (void)addView:(NSView *)view label:(NSString *)label;
- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image;

- (BOOL)crossFade;
- (void)setCrossFade:(BOOL)fade;
- (BOOL)shiftSlowsAnimation;
- (void)setShiftSlowsAnimation:(BOOL)slows;

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;
- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView;
- (NSRect)frameForView:(NSView *)view;


@end
