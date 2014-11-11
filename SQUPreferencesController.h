//
//  SQUPreferencesController.h
//  CacophonyMachine
//
//  Created by Tristan Seifert on 11/9/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString const* kSQUPreferencesControllerKeyPanels;
extern NSString const* kSQUPreferencesControllerKeySaveSettings;

extern NSString const* kSQUPreferencesControllerLastPanel;

@interface SQUPreferencesController : NSWindowController <NSToolbarDelegate> {
	NSToolbar *_toolbar;
	
	NSArray *_panels;
	NSMutableArray *_identifiers;
	
	NSDictionary *_configuration;
}

@end
