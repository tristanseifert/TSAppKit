//
//  TSMouseTrackingView.m
//  Meeper
//
//	An NSView subclass that automatically creates a tracking area for the entire
//	view, and fires a notification whenever the mouse enters or exits the view.
//
//  Created by Tristan Seifert on 11/20/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import "TSMouseTrackingView.h"

// notification keys
NSString *TSMouseTrackingViewMouseEntered = @"me.tseifert.mousetrackingview.right";
NSString *TSMouseTrackingViewMouseLeft = @"me.tseifert.mousetrackingview.left";

NSString *TSMouseTrackingViewMouseDown = @"me.tseifert.mousetrackingview.down";
NSString *TSMouseTrackingViewMouseUp = @"me.tseifert.mousetrackingview.up";

@interface TSMouseTrackingView ()

- (void) setUpTrackingRect;
- (void) cleanUpTrackingRect;

@end

@implementation TSMouseTrackingView

#pragma mark - Initialisation
/**
 * Initialises with a given frame: this is usually called when the view is
 * initialised from code.
 */
- (id) initWithFrame:(CGRect) aRect {
	if((self = [super initWithFrame:aRect])) {
		[self setUpTrackingRect];
	}
	return self;
}

/**
 * Initialises the view with the given coder. Called when loaded from a NIB.
 */
- (id)initWithCoder:(NSCoder *) coder {
	if ((self = [super initWithCoder:coder])) {
		[self setUpTrackingRect];
	}
	return self;
}

#pragma mark - Tracking Area
/**
 * Sets up the tracking area, for the entire bounds of the view.
 */
- (void) setUpTrackingRect {
	_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
												 options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect
												   owner:self
												userInfo:nil];
	
	[self addTrackingArea:_trackingArea];
}

/**
 * Removes the tracking area.
 */
- (void) cleanUpTrackingRect {
	[self removeTrackingArea:_trackingArea];
}

/**
 * Mouse down: send TSMouseTrackingViewMouseDown notification.
 */
- (void) mouseDown:(NSEvent *) theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:TSMouseTrackingViewMouseDown
														object:self];
}

/**
 * Mouse up: send TSMouseTrackingViewMouseUp notification.
 */
- (void) mouseUp:(NSEvent *) theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:TSMouseTrackingViewMouseUp
														object:self];
}

/**
 * Mouse entry: send TSMouseTrackingViewMouseEntered notification.
 */
- (void) mouseEntered:(NSEvent *) theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:TSMouseTrackingViewMouseEntered
														object:self];
}

/**
 * Mouse exit: send TSMouseTrackingViewMouseLeft notification.
 */
- (void) mouseExited:(NSEvent *) theEvent {
	[[NSNotificationCenter defaultCenter] postNotificationName:TSMouseTrackingViewMouseLeft
														object:self];
}

@end
