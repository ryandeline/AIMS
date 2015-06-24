//
//  SyncEngine.h
//  flightlog
//
//  Created by Chris Frederick on 10/8/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import <dispatch/dispatch.h>
#import "MBProgressHUD.h"
#import "Aircraft.h"

typedef void(^ImageSyncCallback)(NSError *error);

@interface SyncEngine : NSObject <MBProgressHUDDelegate>
{
    
}
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property NSManagedObjectContext *context;
@property NSString *tailNumber;
@property dispatch_queue_t backgroundQueue;
@property NSManagedObjectContext *backgroundContext;
//-(BOOL) syncAircraftWithManagedObjectContext: (NSManagedObjectContext *)context;
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
-(BOOL) startSyncForTailNumber:(NSString*)tailNumber withManagedObjectContext:(NSManagedObjectContext *)context viewController:(UIView *)view;
+(void) syncAircraftImages:(ImageSyncCallback)callback;
+(Aircraft*) findAircraftForTailNumber:(NSString *)tailNumber inManagedObjectContext:(NSManagedObjectContext*) context;
@property MBProgressHUD *HUD;
@property MBProgressHUD *refreshHUD;
@end
