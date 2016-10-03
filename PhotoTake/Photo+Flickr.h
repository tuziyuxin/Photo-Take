//
//  Photo+Flickr.h
//  PhotoTaker
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "Photo.h"
#import "Photographer+Create.h"

@interface Photo (Flickr)


+(Photo *) photoWithFlickrInfo:(NSDictionary*)info inManagedObjectContext:(NSManagedObjectContext*)context;

+(void) loadPhotosFromFlickrArray:(NSArray*) array inManagedObjectContext:(NSManagedObjectContext*)context;

@end
