//
//  TSCoreData.m
//  TSAppKit
//
//  Created by Tristan Seifert on 11/25/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TSCoreData.h"

NSString* const TSCoreDataErrorDomain = @"TSCoreDataErrorDomain";
NSString* const TSCoreDataLoadingErrorNotification = @"TSCoreDataLoadingErrorNotification";

static TSCoreData *sharedInstance = nil;

@implementation TSCoreData
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

/**
 *Returns the shared instance of TSCoreData.
 */
+ (instancetype) sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[TSCoreData alloc] init];
	});
	
	return sharedInstance;
}

/**
 * Returns the application document directory.
 */
- (NSURL *) applicationDocumentsDirectory {
	NSString *ident = [[NSBundle mainBundle] bundleIdentifier];
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	return [appSupportURL URLByAppendingPathComponent:ident];
}

/**
 * Creates the managed object model, if needed. We try to find "TSCoreData.momd"
 * in the main bundle.
 */
- (NSManagedObjectModel *) managedObjectModel {
	if (_managedObjectModel) {
		return _managedObjectModel;
	}
	
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TSAppKit" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

/**
 * Creates a persistent store coordinator, with lightweight migration enabled.
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
	BOOL shouldFail = NO;
	NSError *error = nil;
	NSString *failureReason = @"There was an error creating or loading the application's saved data.";
	
	// Make sure the application files directory is there
	NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
	if (properties) {
		if (![properties[NSURLIsDirectoryKey] boolValue]) {
			failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
			shouldFail = YES;
		}
	} else if ([error code] == NSFileReadNoSuchFileError) {
		error = nil;
		[fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
	}
	
	// There's no errors so far, so try to allocate a persistent store coordinator.
	if (!shouldFail && !error) {
		NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
		NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"TSAppKit.sqlite"];
		
		// Options to use when adding this store: lightweight migration
		NSDictionary *options = @{
								  NSMigratePersistentStoresAutomaticallyOption : @YES,
								  NSInferMappingModelAutomaticallyOption : @YES
								  };
		
		// Attempt to add the SQLite persistent store to the coordinator.
		if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
			coordinator = nil;
		}
		
		_persistentStoreCoordinator = coordinator;
	}
	
	// If there were errors, report them modally.
	if (shouldFail || error) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
		dict[NSLocalizedFailureReasonErrorKey] = failureReason;
		if (error) {
			dict[NSUnderlyingErrorKey] = error;
		}
		
		// Create an NSError to encapsulate the issue
		error = [NSError errorWithDomain:TSCoreDataErrorDomain code:9999
								userInfo:dict];
		
		// Post a notification with this error
		[[NSNotificationCenter defaultCenter] postNotificationName:TSCoreDataLoadingErrorNotification
															object:nil
														  userInfo:@{@"error" : error}];
	}
	
	return _persistentStoreCoordinator;
}

/**
 * Creates a managed object context, bound to the persistent store.
 */
- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
		return nil;
	}
	
	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	
	return _managedObjectContext;
}

#pragma mark - Saving
/**
 * Saves the context.
 *
 * @param outError Address of an NSError* pointer, to which error information is
 * written.
 * @return YES if successful, NO otherwise.
 */
- (BOOL) saveContext:(NSError **) outError {
	if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
	}
	
	NSError *error = nil;
	if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
		if(outError) *outError = error;
		return NO;
	}
	
	return YES;
}

#pragma mark - App Delegate Support
/**
 * Can be called by the application delegate to determine whether the app should
 * terminate, validating if the context has been saved.
 */
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *) sender {
	if (!_managedObjectContext) {
		return NSTerminateNow;
	}
	
	if (![[self managedObjectContext] commitEditing]) {
		NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
		return NSTerminateCancel;
	}
	
	if (![[self managedObjectContext] hasChanges]) {
		return NSTerminateNow;
	}
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
		
		BOOL result = [sender presentError:error];
		if (result) {
			return NSTerminateCancel;
		}
		
		NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
		NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
		NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
		NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:question];
		[alert setInformativeText:info];
		[alert addButtonWithTitle:quitButton];
		[alert addButtonWithTitle:cancelButton];
		
		NSInteger answer = [alert runModal];
		
		if (answer == NSAlertFirstButtonReturn) {
			return NSTerminateCancel;
		}
	}
	
	return NSTerminateNow;
}

@end
