//
//  FlickrFetchCDFRC.h
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "CoreDataFetchResultsController.h"

@interface FlickrFetchCDFRC : CoreDataFetchResultsController

@property(nonatomic,strong)NSManagedObjectContext* context;

@end
