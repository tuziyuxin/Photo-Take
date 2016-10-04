//
//  PhotosViewController.m
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "PhotosViewController.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "FlickrFetchCDFRC.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell =[self.tableView dequeueReusableCellWithIdentifier:@"photo view cell"];
    Photo* photo=[self.fetchResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=photo.title;
    cell.detailTextLabel.text=photo.unique;
    return cell;
}

-(void)prepareController:(ImageViewController *)controller index:(NSIndexPath*)index fetchController:(NSFetchedResultsController*) fetchResultController
{
    Photo* photo=[fetchResultController objectAtIndexPath:index];
    controller.title=photo.title;
    controller.imageURL=photo.imageURL;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"this is photosViewController");
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail=self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        UINavigationController* naVC=(UINavigationController*)detail;
        if ([naVC.topViewController isKindOfClass:[ImageViewController class]]) {
            ImageViewController* imageVC=(ImageViewController*)naVC.topViewController;
            [self prepareController:imageVC index:indexPath fetchController:self.fetchResultsController];
        }
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#warning sender is a cell
    NSIndexPath* index=[self.tableView indexPathForCell:sender];
    
    if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
        ImageViewController* pvc=(ImageViewController*)segue.destinationViewController;
        /*
#warning is it a key?
        [self prepareController:pvc ];
        pvc.imageURL=photo.imageURL;
         */
        [self prepareController:pvc index:index fetchController:self.fetchResultsController];
        
    }
}

@end
