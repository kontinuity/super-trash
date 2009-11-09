#import <Cocoa/Cocoa.h>

@interface NotificationView : NSView {
  NSTrackingArea *trackingArea;
}

@property (retain) NSTrackingArea *trackingArea;

@end
