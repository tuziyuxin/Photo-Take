//
//  Photographer+Create.h
//  PhotoTaker
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+(Photographer*)loadPhotographerWithName:(NSString*)name inManagedObjectContext:(NSManagedObjectContext *) context;
@end
