//
//  AppDelegate+Create.h
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "AppDelegate.h"
#import  <CoreData/CoreData.h>

@interface AppDelegate (Create)

-(NSManagedObjectContext*)createManagedObjectContext;

@end
