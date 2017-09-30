//
//  AppDelegate.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/17/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, RootType) {
    Signing = 0,
    Home,
    Survey,
    Security
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)logout;

- (void)saveContext;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;
- (void)initalizeRootControllerAs:(RootType)type;

@end

