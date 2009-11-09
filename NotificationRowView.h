#import <Cocoa/Cocoa.h>

@interface NotificationRowView : NSView {
  NSImageView *image;
  NSTextField *label;
  NSButton *button;
}

@property (retain) NSImageView *image;
@property (retain) NSTextField *label;
@property (retain) NSButton *button;

@end
