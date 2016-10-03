//
//  Photo+Flickr.m
//  PhotoTaker
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "Photo+Flickr.h"


@implementation Photo (Flickr)

+(Photo*)photoWithFlickrInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo* photo=nil;
    if (info) {
        //执行抓取过程
        NSString* unique=[info valueForKey:FLICKR_PHOTO_ID];
        NSFetchRequest* request=[NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate=[NSPredicate predicateWithFormat:@" unique = %@",unique];
        NSError* error=nil;
        NSArray* matches=[context executeFetchRequest:request error:&error];
        
        //判断抓取的结果
        if (!matches || error ||[matches count] >1) {
            //handle error
            NSLog(@"the fetch process is error %@",error.userInfo);
        }else if([matches count])
        {
            photo= [matches lastObject];
        }else
        {
            photo=[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title=[info valueForKey:FLICKR_PHOTO_TITLE];
            photo.subTitle=[info valueForKey:FLICKR_PHOTO_DESCRIPTION];
            photo.imageURL=[[FlickrFetcher URLforPhoto:info format:FlickrPhotoFormatLarge] absoluteString];
            photo.photographer=[Photographer loadPhotographerWithName:[info valueForKey:FLICKR_PHOTO_OWNER] inManagedObjectContext:context];
        }
    }
    
    
    return photo;
}

+(void)loadPhotosFromFlickrArray:(NSArray *)array inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (array) {
        for (NSDictionary* info in array) {
            [self photoWithFlickrInfo:info inManagedObjectContext:context];
        }
    }
}
@end
