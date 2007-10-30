#import "PrefController.h"

@implementation PrefController

- (void)setupToolbar
{
  [self addView:generalPrefsView label:@"General"];
  [self addView:soundPrefsView label:@"Sound"];
}

@end
