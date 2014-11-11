//
//  TSPreferencesController.m
//  TSAppKit
//
//  Created by Tristan Seifert on 11/9/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import "TSPreferencesController.h"

// Keys in configuration file
NSString* kTSPreferencesControllerKeyPanels = @"panels";
NSString* kTSPreferencesControllerKeySaveSettings = @"saveState";

// Keys in user defaults
NSString* kTSPreferencesControllerLastPanel = @"TSPreferencesControllerLastPanel";

@interface TSPreferencesController ()

- (void) toolbarItemSelected:(id) sender;
- (void) updateWithIdentifier:(NSString *) identifier andAnimation:(BOOL) animate;

@end

@implementation TSPreferencesController

/**
 * Custom initialiser to make life easier
 */
- (id) init {
	if(self = [super initWithWindowNibName:@"TSPreferencesController"]) {
		
	}
	
	return self;
}

/**
 * Sets up the toolbar.
 */
- (void) windowDidLoad {
    [super windowDidLoad];
	
	// Load general configuration
	_configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TSPreferencesPanels" ofType:@"plist"]];
	_panels = _configuration[kTSPreferencesControllerKeyPanels];
	
	_identifiers = [NSMutableArray new];
	
	NSAssert(_panels, @"Couldn't load/decode TSPreferencesPanels.plist. See docs for more information.");
	NSAssert(_panels, @"panels key did not exist in TSPreferencesPanels.plist. See docs for more information.");
	
	for (NSDictionary *dict in _panels) {
		[_identifiers addObject:dict[@"identifier"]];
	}
	
	// Set up toolbar
	_toolbar = [[NSToolbar alloc] initWithIdentifier:@"TSPreferencesController"];
	_toolbar.allowsUserCustomization = NO;
	_toolbar.delegate = self;
	
	self.window.toolbar = _toolbar;
	
	// If the last panel is saved, restore it. Otherwise, select first item.
	if([_configuration[kTSPreferencesControllerKeySaveSettings] boolValue]) {
		NSString *lastPanel = [[NSUserDefaults standardUserDefaults] objectForKey:kTSPreferencesControllerLastPanel];
		
		// validate that the panel exists
		if([_identifiers containsObject:lastPanel]) {
			[_toolbar setSelectedItemIdentifier:lastPanel];
		} else {
			[_toolbar setSelectedItemIdentifier:_identifiers[0]];
		}
	} else {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kTSPreferencesControllerLastPanel];
		[_toolbar setSelectedItemIdentifier:_identifiers[0]];
	}
	
	// update the UI
	[self updateWithIdentifier:_toolbar.selectedItemIdentifier andAnimation:NO];
}

#pragma mark - Toolbar
/**
 * Creates an NSToolbarItem from its description in the configuration file.
 */
- (NSToolbarItem *) toolbar:(NSToolbar *) toolbar itemForItemIdentifier:(NSString *) itemIdentifier willBeInsertedIntoToolbar:(BOOL) flag {
	NSDictionary *itemInfo = nil;
	
	// try to find it
	for (NSDictionary *dict in _panels) {
		if([dict[@"identifier"] isEqualToString:itemIdentifier]) {
			itemInfo = dict;
			break;
		}
	}
	
	NSAssert(itemInfo, @"Could not find preferences item: %@", itemIdentifier);
	
	// determine icon name
	NSImage *icon = [NSImage imageNamed:itemInfo[@"icon"]];
	if(!icon) {		
		icon = [NSImage imageNamed:NSImageNamePreferencesGeneral];
	}
	
	// build the toolbar item
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	item.label = itemInfo[@"title"];
	item.image = icon;

	item.target = self;
	item.action = @selector(toolbarItemSelected:);
	
	return item;
}

/**
 * Returns the identifiers of the panels.
 */
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar {
	return _identifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar {
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *) toolbarSelectableItemIdentifiers:(NSToolbar *) toolbar {
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

#pragma mark - Selection and View Updating
/**
 * Called when a toolbar item is actually selected.
 */
- (void) toolbarItemSelected:(id) sender {
	NSToolbarItem *item = sender;
	[self updateWithIdentifier:item.itemIdentifier andAnimation:YES];
}

/**
 * Called to update the user interface with a new pane. Does the grunt work of
 * reconfiguring the window, and updating the title.
 *
 * @param animate When NO, no animation is performed, and the window will not
 * be automatically displayed.
 */
- (void) updateWithIdentifier:(NSString *) identifier andAnimation:(BOOL) animate {
	NSDictionary *itemInfo = nil;
	
	// try to find it
	for (NSDictionary *dict in _panels) {
		if([dict[@"identifier"] isEqualToString:identifier]) {
			itemInfo = dict;
			break;
		}
	}
	NSAssert(itemInfo, @"Could not find preferences item: %@", identifier);
	
	// Load the controller
	NSString *class = itemInfo[@"class"];
	if(NSClassFromString(class)) {
		NSViewController *ctrlr = [[NSClassFromString(class) alloc] init];
		
		// get the old view
		NSView *oldView = self.window.contentView;
		
		// update content view
		NSView *view = ctrlr.view;
		if (oldView == view)
			return;
		
		NSRect windowRect = self.window.frame;
		
		// calculate size differences
		CGFloat difference = (NSHeight([view frame]) - NSHeight(oldView.frame)) * [self.window backingScaleFactor];
		windowRect.origin.y -= difference;
		windowRect.size.height += difference;
		
		difference = (NSWidth([view frame]) - NSWidth([self.window.contentView frame])) * [self.window backingScaleFactor];
		windowRect.size.width += difference;
		
		[view setHidden:YES];
		[self.window setContentView:view];
		[self.window setFrame:windowRect display:animate animate:animate];
		[view setHidden:NO];
	} else {
		NSAssert(false, @"Couldn't load %@", class);
	}
	
	// update window title
	self.window.title = itemInfo[@"title"];
	
	// store selected item
	if([_configuration[kTSPreferencesControllerKeySaveSettings] boolValue]) {
		[[NSUserDefaults standardUserDefaults] setObject:identifier
												  forKey:kTSPreferencesControllerLastPanel];
	}
}

@end
