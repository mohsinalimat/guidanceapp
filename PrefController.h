#import <Cocoa/Cocoa.h>

@interface PrefController : NSObject {
    IBOutlet NSToolbarItem *tbItem_general;
    IBOutlet NSToolbarItem *tbItem_sound;
    IBOutlet NSWindow *window_preferences;
    IBOutlet NSMatrix *rad_asrMethod;
    IBOutlet NSMatrix *rad_ishaMethod;
    IBOutlet NSTextField *text_latitude;
    IBOutlet NSTextField *text_longitude;
}
- (IBAction)radAsr_changed:(id)sender;
- (IBAction)radIsha_changed:(id)sender;
- (IBAction)textLat_changed:(id)sender;
- (IBAction)textLon_changed:(id)sender;
@end
