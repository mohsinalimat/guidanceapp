//
//  GrowlHandler.m
//  Guidance
//
//  Created by Matthew Crenshaw on 10/22/07.
//  Copyright 2007 Batoul Apps. All rights reserved.
//

#import "Growler.h"
#import <Growl-WithInstaller/Growl.h>
#import "Prayer.h"

#define NotificationName  @"Guidance Notification"

@implementation Growler

- (id) init
{
	if ((self = [super init]))
	{
		[GrowlApplicationBridge setGrowlDelegate:self];
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (NSDictionary *) registrationDictionaryForGrowl
{
		NSArray *notifications = [NSArray arrayWithObjects:
				NotificationName,
				nil];

		NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
				@"Guidance", GROWL_APP_NAME,
				notifications, GROWL_NOTIFICATIONS_ALL,
				notifications, GROWL_NOTIFICATIONS_DEFAULT,
				nil];

	return regDict;
}

- (void) doGrowl : (NSString *) title : (NSString *) desc : (BOOL) sticky
{
	[GrowlApplicationBridge notifyWithTitle:title
					description:desc
					notificationName:NotificationName
					iconData: nil
					priority:0
					isSticky:sticky
					clickContext:@""];
}



- (void) growlNotificationWasClicked:(id)clickContext 
{
	
	NSAlert* alert = [NSAlert new];
    [alert setInformativeText: @"Informative text"];
    [alert setMessageText:     @"Message text"];
    [alert runModal];
	
}


 - (BOOL) isInstalled 
 {
  return [GrowlApplicationBridge isGrowlInstalled];
 }

@end
