//
//  FlickrFetchCDFRC.m
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "FlickrFetchCDFRC.h"
#import "Photographer.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosViewController.h"

@interface FlickrFetchCDFRC ()
@end

@implementation FlickrFetchCDFRC
#warning context is observed
-(void)awakeFromNib
{
#warning this should be changed,用预定义就不会报错
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *  note) {
                                                      self.context=note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
    if ([self.splitViewController.viewControllers[0] isKindOfClass:[UINavigationController class]]) {
        self.splitViewController.viewControllers[0].title=@"Master";
    }
    self.navigationItem.title=@"Photographer";
}
-(void)viewDidLoad
{
    if (self.navigationController) {
        NSLog(@"%lu COUNT",[self.navigationController.viewControllers count]);
    }
}

-(void)setContext:(NSManagedObjectContext *)context
{
    _context=context;
    NSFetchRequest* fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending: YES
                                                                    selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:context
                                              sectionNameKeyPath:nil
                                              cacheName:nil];
    self.fetchResultsController=controller;
}
#pragma mark - UITableViewDataSource

-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell =[self.tableView dequeueReusableCellWithIdentifier:@"table view cell"];
    Photographer* photographer=[self.fetchResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=photographer.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%lu photos",[photographer.photos count]];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   // UITableViewCell* cell=[self.tableView dequeueReusableCellWithIdentifier:@"table view cell"];
    if ([segue.identifier isEqualToString:@"cell photo"]) {
        NSIndexPath* index=[self.tableView indexPathForSelectedRow];
        Photographer* photographer=[self.fetchResultsController objectAtIndexPath:index];
    
       if ([segue.destinationViewController isKindOfClass:[PhotosViewController class]]) {
        
        PhotosViewController* pvc=(PhotosViewController*)segue.destinationViewController;
        NSFetchRequest* fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        fetchRequest.predicate=[NSPredicate predicateWithFormat:@"photographer = %@",photographer];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"unique"
                                                                       ascending: YES
                                                                        selector:@selector(localizedStandardCompare:)];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                                  initWithFetchRequest:fetchRequest
                                                  managedObjectContext:self.context
                                                  sectionNameKeyPath:nil
                                                  cacheName:nil];
        pvc.navigationItem.title=@"Photos";
        
        pvc.fetchResultsController=controller;
        }
        
    }
}
@end
