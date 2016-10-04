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

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *unique;
@property (nonatomic, retain) Photographer *photographer;

@end
