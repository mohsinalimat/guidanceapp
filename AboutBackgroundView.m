//
//  AboutBackgroundView.m
//  Guidance
//
//  Created by Matthew Crenshaw on 11/9/07.
//  Copyright 2007 BatoulApps. All rights reserved.
//

#import "AboutBackgroundView.h"


@implementation AboutBackgroundView

- (void)drawRect:(NSRect)rect
{
	// Load the image.
	NSImage *bgImage = [NSImage imageNamed:@"aboutbg"];
	
	NSPoint drawPoint;
	drawPoint.x = 0;
	drawPoint.y = 0;
	
	// Draw it.
	[bgImage drawAtPoint:drawPoint
			fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			fraction:1.0];
}

@end
