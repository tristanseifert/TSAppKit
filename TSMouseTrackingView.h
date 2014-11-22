//
//  TSMouseTrackingView.h
//  Meeper
//
//  Created by Tristan Seifert on 11/20/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *TSMouseTrackingViewMouseEntered;
extern NSString *TSMouseTrackingViewMouseLeft;
extern NSString *TSMouseTrackingViewMouseDown;
extern NSString *TSMouseTrackingViewMouseUp;

@interface TSMouseTrackingView : NSView {
	NSTrackingArea *_trackingArea;
}

@end
