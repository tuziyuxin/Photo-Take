//
//  Photographer+Create.m
//  PhotoTaker
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+(Photographer*)loadPhotographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer* photographer=nil;
    if ([name length]) {
        NSFetchRequest* request=[NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate=[NSPredicate predicateWithFormat:@"name = %@",name];
        NSError *error=nil;
        NSArray* matches=[context executeFetchRequest:request error:&error];
        if (!matches|| error||[matches count]>1) {
            //handle error
        }else if([matches count])
        {
            photographer=[matches lastObject];//matches 始终是NSArray!!!!!
        }else
        {
            photographer=[NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name=name;
        }
    }
    return photographer;
}

@end
