#import "NotificationView.h"

@implementation NotificationView

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

@end
