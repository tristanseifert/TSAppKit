//
//  TSCoreData.h
//  TSAppKit
//
//  Created by Tristan Seifert on 11/25/14.
//  Copyright (c) 2014 Tristan Seifert. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

extern NSString* const TSCoreDataErrorDomain;
extern NSString* const TSCoreDataLoadingErrorNotification;

@interface TSCoreData : NSObject

+ (instancetype) sharedInstance;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 * Saves the context.
 *
 * @param outError Address of an NSError* pointer, to which error information is
 * written.
 * @return YES if successful, NO otherwise.
 */
- (BOOL) saveContext:(NSError **) outError;

@end
