#import <Cocoa/Cocoa.h>

@interface NotificationWindow : NSWindow {
  NSPoint initialLocation;
}

@property (assign) NSPoint initialLocation;

@end