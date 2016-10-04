 //
//  AppDelegate+Create.m
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//
#import "AppDelegate+Create.h"

@implementation AppDelegate (Create)

-(NSManagedObjectContext*)createManagedObjectContext
{
    NSManagedObjectContext* context=nil;
    NSPersistentStoreCoordinator* coordinator=[self persistentStoreCoordinator];
    if (coordinator) {
        context=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}

-(NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    NSPersistentStoreCoordinator* coordinator=nil;
    NSURL * storeURL=[[self applicationDocumentDirectory] URLByAppendingPathComponent:@"Photo.sqlite"];
    NSError* error=nil;
    NSFileManager* manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[storeURL path]]) {
        NSError* error2=nil;
        [manager removeItemAtPath:[storeURL path] error:&error2];
        if (error2) {
            NSLog(@"delete errors:persistentStoreCoordinator");
        }
    }
    coordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                  configuration:nil
                                            URL:storeURL
                                        options:nil
                                          error:&error])
    {
        NSLog(@"the persisten store fails %@",error.userInfo);
    }
    
    return coordinator;
}

-(NSManagedObjectModel*) managedObjectModel
{
    NSURL* url=[[NSBundle mainBundle] URLForResource:@"PhotoScheme" withExtension:@"mom"];
    NSManagedObjectModel* model=nil;
    model=[[NSManagedObjectModel alloc] initWithContentsOfURL:url];//需要coredata
    return model;
    
}


-(NSURL*)applicationDocumentDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
