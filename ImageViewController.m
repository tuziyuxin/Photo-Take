//
//  ImageViewController.m
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()<UIScrollViewDelegate,UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UIScrollView *scollView;
@property(nonatomic,strong)UIImage* image;
@property(nonatomic,strong)UIImageView * imageView;
@end

@implementation ImageViewController

-(void)viewDidLoad
{
    [self.scollView addSubview:self.imageView];
}
-(void)setScollView:(UIScrollView *)scollView
{
    _scollView=scollView;
    _scollView.minimumZoomScale = 0.2;
    _scollView.maximumZoomScale = 2.0;
    _scollView.delegate = self;
    self.scollView.contentSize = self.image ? self.image.size : CGSizeZero;

}
-(UIImageView*)imageView
{
    if (!_imageView) {
        _imageView=[[UIImageView alloc] init];
    }
    return _imageView;
}

-(void)setImageURL:(NSString *)imageURL
{
    if ([imageURL isEqualToString:_imageURL]) {
        return;
    }
    self.image=nil;
    //self.scollView.scrollEnabled=NO;
    [self.spinner startAnimating];
    _imageURL=imageURL;
    [self startDownloadImage:imageURL];
    
}
-(void)setImage:(UIImage *)image
{
    _image=image;
    
    self.imageView.image=image;//image会根据imageview自动设置大小
    
    CGFloat widthScale=self.scollView.frame.size.width/image.size.width;
    CGFloat heightScale=self.scollView.frame.size.height/image.size.height;
    if (image) {
        self.imageView.frame=CGRectMake(0, 0,image.size.width,image.size.height);
        CGFloat width=image.size.width*widthScale;
        CGFloat height=image.size.height*heightScale;
        self.imageView.frame=CGRectMake(0, 0, width,height);
    }
    
    self.scollView.zoomScale=1;//和image没有关系
    self.scollView.minimumZoomScale=1;
    
    self.scollView.contentSize=self.imageView.frame.size;
    self.scollView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.spinner stopAnimating];

    
}
-(void)startDownloadImage:(NSString*) imageURL
{
    if (imageURL) {
        
        NSURLSessionConfiguration* configuration=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.allowsCellularAccess=NO;
        NSURLSession* session=[NSURLSession sessionWithConfiguration:configuration];
        
        NSURLRequest* request=[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                            } else {
                                                                if ([self.imageURL isEqualToString:imageURL])
                                                                {
#warning there is not need to be serization
                                                                    UIImage* image=[UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                }
                                                            }
                                                        }];
        [task resume];

    }
   
    
}
#pragma mark -UIScrollViewDelegate
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    
}
#pragma mark - UISplitViewControllerDelegate

// this section added during Shutterbug demo

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

-(UIInterfaceOrientation)splitViewControllerPreferredInterfaceOrientationForPresentation:(UISplitViewController *)splitViewController
{
    return UIInterfaceOrientationLandscapeLeft;
}

@end
