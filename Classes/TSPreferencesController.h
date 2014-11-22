//
//  TSPreferencesController.h
//  TSAppKit
//
//  Created by Tristan Seifert on 11/9/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString const* kTSPreferencesControllerKeyPanels;
extern NSString const* kTSPreferencesControllerKeySaveSettings;

extern NSString const* kTSPreferencesControllerLastPanel;

/**
 * TSPreferencesController controls the display of a preferences window, based
 * on a set of options in a preferences file.
 */
@interface TSPreferencesController : NSWindowController <NSToolbarDelegate> {
	NSToolbar *_toolbar;
	
	NSArray *_panels;
	NSMutableArray *_identifiers;
	NSString *_currentPanel;
	
	NSDictionary *_configuration;
}

/**
 * Contains a reference to teh currently displayed view controller. We are KVO
 * compliant for this key.
 */
@property (nonatomic, readonly) NSViewController *currentController;

@end
