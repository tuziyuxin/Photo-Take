//
//  CoreDataFetchResultsController.h
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface CoreDataFetchResultsController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic,strong)NSFetchedResultsController* fetchResultsController;

-(void)perfromFetch;//在设置里面进行调用

@end
