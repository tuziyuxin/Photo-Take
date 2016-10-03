//
//  Photo.h
//  PhotoTaker
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FlickrFetcher.h"
#import "Photographer.h"

@class Photographer;

@interface Photo:NSManagedObject

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *subTitle;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *unique;
@property (nullable, nonatomic, retain) Photographer *photographer;

@end
