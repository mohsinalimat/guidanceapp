//
//  UserDefaults.m
//  Guidance
//
//  Created by Matthew Crenshaw on 10/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "UserDefaults.h"


@implementation UserDefaults

-(void)saveToUserDefaults:(NSString*)myString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"Prefs"];
		[standardUserDefaults synchronize];
	}
}

-(NSString*)retrieveFromUserDefaults
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"Prefs"];
	
	return val;
}

@end
