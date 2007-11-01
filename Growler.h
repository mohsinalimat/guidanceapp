//
//  Growler.h
//  Guidance
//
//  Created by Matthew Crenshaw on 10/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Growler : NSObject
{

}

- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky ;

- (void) growlNotificationWasClicked:(id)clickContext;

 - (BOOL) checkGrowl;

@end
