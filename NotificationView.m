#import "NotificationView.h"

@implementation NotificationView

@synthesize trackingArea;

- (void) awakeFromNib {
  self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                              options: ( NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
                                                owner:self userInfo:nil];
  [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)rect {
  [[NSColor clearColor] set];
  NSRectFill([self frame]);
  
  NSDrawThreePartImage([self frame],
                       [NSImage imageNamed:@"window_top"],
                       [NSImage imageNamed:@"window_center"], 
                       [NSImage imageNamed:@"window_bottom"],
                       YES, NSCompositeSourceOver, 1.0, NO);
    
  [[self window] setHasShadow:NO];
  [[self window] setHasShadow:YES];  
}

- (void)mouseEntered:(NSEvent *)theEvent {
  NSLog(@"Mouse entered");
}

- (void)updateTrackingAreas {
  [self removeTrackingArea:trackingArea];
  [trackingArea release];
  trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                              options: (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                              owner:self userInfo:nil];
  [self addTrackingArea:trackingArea];
}

@end
