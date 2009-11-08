#import "NotificationWindow.h"
#import <AppKit/AppKit.h>

@implementation NotificationWindow

- (id) initWithContentRect:(NSRect) contentRect styleMask:(NSUInteger) aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
  self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
  if (self != nil) {
    [self setAlphaValue:0.0f];
    [self setOpaque:NO];
  }
  return self;
}

- (BOOL) canBecomeKeyWindow {
  return YES;
}

@end
