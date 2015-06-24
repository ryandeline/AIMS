//
//  SyncEngine.m
//  flightlog
//
//  Created by Chris Frederick on 10/8/12.
//  Copyright (c) 2012 Chris Frederick. All rights reserved.
//

#import "SyncEngine.h"
#import <objc/runtime.h>
#import "LogEntry.h"
#import <objc/objc-sync.h>


@implementation SyncEngine

- (SyncEngine*) init {
    SyncEngine *s = [super init];
    
    s.backgroundQueue = dispatch_queue_create("com.tinyowlapps.flightlog.bgqueue", DISPATCH_QUEUE_SERIAL);
        
    return s;
}

// Update the IU on the sync progress.
- (void) setSyncStatusMessage:(NSString *) message {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"syncUpdate" object:message];
}

- (void) dealloc {
    //dispatch_release(self.backgroundQueue);
}

// Register one-way sync tables with this function.  Only handles read-only tables at the moment.
- (void)registerNSManagedObjectClassToSync:(Class)aClass {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
        
    }
    
    if ([aClass isSubclassOfClass:[NSManagedObject class]]) {
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
}

+(Aircraft*) findAircraftForTailNumber:(NSString *)tailNumber inManagedObjectContext:(NSManagedObjectContext*) context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Aircraft" inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Specify that the request should return dictionaries.
    //[request setResultType:NSDictionaryResultType];
    
    //optionally set a predicate
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"tailNumber == %@",
                              tailNumber];
    [request setPredicate:predicate];
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        NSLog(@"Error! Could not retrive Aircraft for tailnumber %@", tailNumber );
        return nil;
    }
    else {
        // Note: maxUpdateAt could be null.
        //NSLog(@"Max date: %@", [[objects objectAtIndex:0] valueForKey:@"maxUpdatedAt"]);
        return [objects objectAtIndex:0];
    }
}

-(NSDate*) maxUpdatedAtForEntityName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext*) context withPredicate:(NSPredicate*) predicate {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    
    // Create an expression to represent the max value at the key path 'updatedAt'
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    // Create an expression description using the maxExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"maxUpdatedAt"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    //optionally set a predicate
    if(predicate) {
        [request setPredicate:predicate];
    }
    
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        NSLog(@"Error! Could not retrive max date for table %@", entityName );
        return nil;
    }
    else {
        // Note: maxUpdateAt could be null.
        //NSLog(@"Max date: %@", [[objects objectAtIndex:0] valueForKey:@"maxUpdatedAt"]);
        return [[objects objectAtIndex:0] valueForKey:@"maxUpdatedAt"];
    }
}

-(NSManagedObject*) findObjectId:(NSString *)objectId forEntityName:(NSString *) entityName fromManagedObjectContext:(NSManagedObjectContext *) context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"objectId == %@",
                              objectId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if(objects == nil) {
        NSLog(@"Error! could not find objectId %@", objectId);
        return nil;
    } else {
        if(objects.count >0) {
            return [objects objectAtIndex:0];
        }
        else
            return nil;
    }
}

-(BOOL) deleteObjectId:(NSManagedObject *)object fromManagedObjectContext:(NSManagedObjectContext *) context {
    [context deleteObject:object];
    [context save:nil];
    
    return YES;
}

-(BOOL) startSyncForTailNumber:(NSString*)tailNumber withManagedObjectContext:(NSManagedObjectContext *)context viewController:(UIView *)view{

    NSLog(@"Showing Refresh HUD");
    _refreshHUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:_refreshHUD];
	
    // Register for HUD callbacks so we can remove it from the window at the right time
    _refreshHUD.delegate = self;
	_refreshHUD.labelText = @"Downloading Data";
    // Show the HUD while the provided method executes in a new thread
    [_refreshHUD show:YES];
    

    _context = context;
    _tailNumber = tailNumber;
    for (NSString *className in self.registeredClassesToSync) {
        //1. Find the max syncDate in local storage.
        NSDate *lastSyncDate = [self maxUpdatedAtForEntityName:className inManagedObjectContext:context withPredicate:nil];
        
        //2. Retrive records from parse we want to sync to local storage
        PFQuery *query = [PFQuery queryWithClassName:className];
        if(lastSyncDate != nil)
        {
            [query whereKey:@"updatedAt" greaterThan:lastSyncDate];
        }
        //[query orderByAscending:@"objectId"]; get record count for teable.  order the table, set limit to smaller number, keep track of progress.  use skip to start at next position.  loop until no records left.
        //hardcode the limit to 1000 for the short term, we'll need to improve this batch size to get all records using limit and skip
        query.limit = 100;
        
        //3a. Determine the list of properties for this object that we want to auto-populate
        NSString *propertyName;
        NSMutableArray *propertyArray = [[NSMutableArray alloc] initWithCapacity:999];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(NSClassFromString(className), &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            propertyName = [NSString stringWithUTF8String:property_getName(property)];
            if([propertyName isEqualToString:@"updatedAt"]) {
                continue;
            } else if([propertyName isEqualToString:@"objectId"]) {
                continue;
            } else if([propertyName isEqualToString:@"createdAt"]) {
                continue;
            } else if([propertyName rangeOfString:@"Entries"].location == NSNotFound){
               // NSLog(@"Adding property: %@",propertyName);
                [propertyArray addObject:[[NSString alloc] initWithString:propertyName]];
            }
        }
        free(properties);
        
        //3. query the objects from parse in our background queue.
        dispatch_async(_backgroundQueue, ^(void) {
            //[self setSyncStatusMessage:[[NSString alloc] initWithFormat:@"Updating %@...", className]];
            int objectCount = 1;
            int skip = 0;
            NSLog(@"updating %@",className);
            _refreshHUD.detailsLabelText = [NSString stringWithFormat: @"Syncing %@", className];
            do {
                NSError *error;
                query.skip = skip;
                
                NSArray *objects = [query findObjects:&error];
                
                if (!error) {
                    objectCount = objects.count;
                    skip = skip + objectCount;
                    //dispatch_sync(dispatch_get_main_queue(), ^{
                        if(objects.count > 0) {
                            //Asyncronosly save the main context.
                            [context performBlockAndWait:^{

                                for(PFObject* parseObject in objects) {
                                    NSString *objectId = parseObject.objectId;
                                    NSDate *updatedAt = parseObject.updatedAt;
                                    NSDate *createdAt = parseObject.createdAt;
                                    NSString *deleteInd = [parseObject objectForKey:@"deleteInd"]; //Supports logical deletion (value must = "Y")
                                    
                                    //find the object in local storage
                                    NSManagedObject *localObject = [self findObjectId:objectId forEntityName:className fromManagedObjectContext:context];
                                    
                                    //DELETE the object from local storage if necessary
                                    if([deleteInd isEqualToString:@"Y"]) {
                                        if(localObject)
                                            [self deleteObjectId:localObject fromManagedObjectContext:context];
                                    }
                                    else //UPDATE OR INSERT the object in local storage
                                    {
                                        //If we didn't find a local object create one.
                                        if (!localObject) {
                                            localObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
                                        }
                                        
                                        //set the standard properties that all local objects must share.
                                        [localObject setValue:objectId forKey:@"objectId"];
                                        [localObject setValue:createdAt forKey:@"createdAt"];
                                        [localObject setValue:updatedAt forKey:@"updatedAt"];
                                        
                                        //set each class specific property in local storage (that we found earlier)
                                        for(NSString *key in propertyArray){
                                            //   NSLog(@"setting localObject value for Key: %@ value %@",key, [parseObject objectForKey:key]);
                                            @try {
                                                [localObject setValue:[parseObject objectForKey:key] forKey:key];
                                            }
                                            @catch (NSException *exception) {
                                                // Print exception information
                                                NSLog( @"NSException caught" );
                                                NSLog( @"Name: %@", exception.name);
                                                NSLog( @"Reason: %@", exception.reason );
                                                [localObject setValue:nil forKey:key];
                                            }                                                
                                        }
                                    }
                                }
                            
                                NSError *error;
                                if (![context save:&error])
                                {
                                    NSLog(@"Failed to save main context");
                                }
                            }];
                            
                        }
                   // });
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    objectCount = 0;
                }
            } while (objectCount >0 );
        });
    }
    
    //after we have downloaded all of the validation tables, kick off the logbook download.
    dispatch_async(_backgroundQueue, ^(void) {
        [self syncLogbookForTailNumber:nil withManagedObjectContext:_context];
    });
                   
    return YES;
}

// This function must be called in our background thread, otherwise we will block the main thread.
-(BOOL) syncLogbookForTailNumber:(NSString*)tailNumber withManagedObjectContext:(NSManagedObjectContext *)context {
    
    if(/*tailNumber == nil || */context == nil)
        return NO;
    
    //1. Find the max syncDate in local storage (with tail number predicate)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:/*@"tailNumber = %@ and */@"syncInd = %@", /*tailNumber,*/ [NSNumber numberWithBool:YES]];
    NSDate *lastSyncDate = [self maxUpdatedAtForEntityName:@"LogEntry" inManagedObjectContext:context withPredicate:predicate];
    
    //2. Retrive records from parse we want to sync to local storage for this aircraft
    PFQuery *query = [PFQuery queryWithClassName:@"LogEntry"];
    if(lastSyncDate != nil)
    {
        [query whereKey:@"updatedAt" greaterThan:lastSyncDate];
    }
    
    // if passed a tail number only sync that plane, but we generally don't do this.
    /*if(_tailNumber != nil)  {
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Aircraft"]; //only ensure for this aircraft.
    
        [innerQuery whereKey:@"tailNumber" equalTo:_tailNumber];
        [query whereKey:@"aircraft" matchesQuery:innerQuery];
    }*/
    
    NSError *error;
    NSInteger recordCount = [query countObjects:&error];
    if(!error)
    {
        NSLog(@"About to download %d logbook records", recordCount);
        _refreshHUD.detailsLabelText = [NSString stringWithFormat: @"Downloading %d LogBook records", recordCount];
    }
    //3. kick off a request to download the logbook entries we don't have (or want to update) locally in the background.
    //[self setSyncStatusMessage:[[NSString alloc] initWithFormat:@"Downloading logbook entries..."]];
    error = nil;
    NSLog(@"start query");
    NSArray *objects = [query findObjects:&error];
    NSLog(@"end query (%u)", [objects count]);
    if (!error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(objects.count > 0) {
                for(PFObject* pfObject in objects) {
                    NSString *objectId = pfObject.objectId;
                    NSString *deleteInd = [pfObject objectForKey:@"deleteInd"];
                    NSDate *updatedAt = pfObject.updatedAt;
                    NSDate *createdAt = pfObject.createdAt;
                    
                    //find the object in local storage
                    NSManagedObject *localObj = [self findObjectId:objectId forEntityName:@"LogEntry" fromManagedObjectContext:context];
                    
                    if([deleteInd isEqualToString:@"Y"]) {
                        //DELETE
                        if(localObj)
                            [self deleteObjectId:localObj fromManagedObjectContext:context];
                    }
                    else
                    {
                        //UPDATE OR INSERT
                        LogEntry *log = nil;
                        if (localObj) {
                            log = (LogEntry *)localObj;
                        }
                        else {
                            log = (LogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"LogEntry" inManagedObjectContext:context];
                        }
                        
                        [log setObjectId:objectId];
                        [log setCreatedAt:createdAt];
                        [log setUpdatedAt:updatedAt];
                        [log setSyncInd:[[NSNumber alloc] initWithBool:YES]];
                        [log setHobbsStart:[pfObject objectForKey:@"hobbsStart"]];
                        [log setHobbsEnd:[pfObject objectForKey:@"hobbsEnd"]];
                        [log setHobbsDuration:[pfObject objectForKey:@"hobbsDuration"]];
                        [log setTachStart:[pfObject objectForKey:@"tachStart"]];
                        [log setTachEnd:[pfObject objectForKey:@"tachEnd"]];
                        [log setTachDuration:[pfObject objectForKey:@"tachDuration"]];
                        [log setTailNumber:[pfObject objectForKey:@"tailNumber"]];
                        [log setToICAO:[pfObject objectForKey:@"toICAO"]];
                        [log setFromICAO:[pfObject objectForKey:@"fromICAO"]];
                    
                        //pilot
                        PFObject *pfPilot = [pfObject objectForKey:@"pilot"];
                        Crew *pilot = (Crew*)[self findObjectId:pfPilot.objectId forEntityName:@"Crew" fromManagedObjectContext:context];
                        if(pilot)
                            log.pilot = pilot;
                        //pilot2
                        PFObject *pfPilot2 = [pfObject objectForKey:@"pilot2"];
                        Crew *pilot2 = (Crew*)[self findObjectId:pfPilot2.objectId forEntityName:@"Crew" fromManagedObjectContext:context];
                        if(pilot2)
                            log.pilot2 = pilot2;
                        //pilot3
                        PFObject *pfPilot3 = [pfObject objectForKey:@"pilot3"];
                        Crew *pilot3 = (Crew*)[self findObjectId:pfPilot3.objectId forEntityName:@"Crew" fromManagedObjectContext:context];
                        if(pilot3)
                            log.pilot3 = pilot3;
                        //pilot4
                        PFObject *pfPilot4 = [pfObject objectForKey:@"pilot4"];
                        Crew *pilot4 = (Crew*)[self findObjectId:pfPilot4.objectId forEntityName:@"Crew" fromManagedObjectContext:context];
                        if(pilot4)
                            log.pilot4 = pilot4;
                        //Project
                        PFObject *pfProject = [pfObject objectForKey:@"project"];
                        Project *project = (Project*)[self findObjectId:pfProject.objectId forEntityName:@"Project" fromManagedObjectContext:context];
                        if(project)
                            log.project = project;
                        //Sensor
                        PFObject *pfSensor = [pfObject objectForKey:@"sensor"];
                        Sensor *sensor = (Sensor*)[self findObjectId:pfSensor.objectId forEntityName:@"Sensor" fromManagedObjectContext:context];
                        if(sensor)
                            log.sensor = sensor;
                        
                        log.comment = [pfObject objectForKey:@"comment"];
                        log.nonFlightReason = [pfObject objectForKey:@"nonFlightReason"];
                        log.logType = [pfObject objectForKey:@"logType"];
                        log.logDate = [pfObject objectForKey:@"logDate"];
                        
                        NSError *error = nil;
                        if (![context save:&error]) {
                            NSLog(@"Holy error batman!");
                        }
                    }
                }
            }
            
            [SyncEngine syncAircraftImages:^(NSError *error) {
                [self setSyncStatusMessage:@"Complete"];
                [_refreshHUD hide:NO];
            }];
            
        });
    } else {
        // Log details of the failure
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }

    
    //4. Kick off a request to upload the *new* local logbook entries we have not synced to parse.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:/*@"tailNumber = %@ and */@"syncInd = %@",/* tailNumber,*/ [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if(error)
    {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
        return NO;
    }
    
    if([results count] == 0) {
        NSLog(@"No unsynced local logbook entries to upload to Parse");
        return YES;
    }
    
    NSLog(@"Syncing %d local entries to cloud", [results count]);
    
    _refreshHUD.detailsLabelText = [NSString stringWithFormat:@"Uploading %d LogBook records", [results count]];
                                    
    for(LogEntry *logEntry in results)
    {
        PFObject *pfLogEntry = [PFObject objectWithClassName:@"LogEntry"];
        [pfLogEntry setObject:logEntry.hobbsStart forKey:@"hobbsStart"];
        [pfLogEntry setObject:logEntry.hobbsEnd forKey:@"hobbsEnd"];
        [pfLogEntry setObject:logEntry.hobbsDuration forKey:@"hobbsDuration"];
        [pfLogEntry setObject:logEntry.tachStart forKey:@"tachStart"];
        [pfLogEntry setObject:logEntry.tachEnd forKey:@"tachEnd"];
        [pfLogEntry setObject:logEntry.tachDuration forKey:@"tachDuration"];
        [pfLogEntry setObject:logEntry.logDate forKey:@"logDate"];
        [pfLogEntry setObject:logEntry.hobbsDuration forKey:@"hobbsDuration"];
        [pfLogEntry setObject:logEntry.logType forKey:@"logType"];
        [pfLogEntry setObject:logEntry.tailNumber forKey:@"tailNumber"];
        if(logEntry.fromICAO)
            [pfLogEntry setObject:logEntry.fromICAO forKey:@"fromICAO"];
        
        if(logEntry.toICAO)
            [pfLogEntry setObject:logEntry.toICAO forKey:@"toICAO"];
        
        if(logEntry.comment)
            [pfLogEntry setObject:logEntry.comment forKey:@"comment"];
        if(logEntry.nonFlightReason)
            [pfLogEntry setObject:logEntry.nonFlightReason forKey:@"nonFlightReason"];

        if(logEntry.pilot)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Crew" objectId:logEntry.pilot.objectId] forKey:@"pilot"];
        if(logEntry.pilot2)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Crew" objectId:logEntry.pilot2.objectId] forKey:@"pilot2"];
        if(logEntry.pilot3)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Crew" objectId:logEntry.pilot3.objectId] forKey:@"pilot3"];
        if(logEntry.pilot4)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Crew" objectId:logEntry.pilot4.objectId] forKey:@"pilot4"];
        
        if(logEntry.project)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Project" objectId:logEntry.project.objectId] forKey:@"project"];
        if(logEntry.sensor)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"Sensor" objectId:logEntry.sensor.objectId] forKey:@"sensor"];
        if(logEntry.maintanceSchedule)
            [pfLogEntry setObject:[PFObject objectWithoutDataWithClassName:@"MaintanceSchedule" objectId:logEntry.maintanceSchedule.objectId] forKey:@"maintanceSchedule"];
        
        NSError *error;
        BOOL bSuccess = [pfLogEntry save:&error];
        if (bSuccess) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                logEntry.objectId = pfLogEntry.objectId;
                logEntry.syncInd = [NSNumber numberWithBool:YES];
                [context save:nil];
                NSLog(@"Saved objectID %@ to parse and then flipped the syncInd and saved locally", logEntry.objectId);
            });
        } else {
            NSLog(@"Crap! we failed to save an object to parse.  Luckly we didn't update it's syncInd so it should try again next time");
        }
    }
    
    
    return YES;
}


+(void) syncAircraftImages:(ImageSyncCallback)callback {
    PFQuery *query = [PFQuery queryWithClassName:@"Aircraft"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %d photos.", objects.count);
            // Let's save the file into Document folder.
            // You can also change this to your desktop for testing. (e.g. /Users/kiichi/Desktop/)
            // NSString *deskTopDir = @"/Users/kiichi/Desktop";
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            for(PFObject *eachObject in objects) {
                PFFile *theImage = [eachObject objectForKey:@"imageFile"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                NSString *jpgFilePath = [NSString stringWithFormat:@"%@/%@.jpg",docDir,[eachObject objectForKey:@"tailNumber"]];
                NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];//1.0f = 100% quality
                [data2 writeToFile:jpgFilePath atomically:YES];
            }
        
        } else {
            // Log details of the failure
            NSLog(@"Error downloading pictures in aircraft class: %@ %@", error, [error userInfo]);
        }
        
        // when you want to call the callback block
        if(callback)
            callback(error);
    }];
}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [hud removeFromSuperview];
	hud = nil;
}
@end
