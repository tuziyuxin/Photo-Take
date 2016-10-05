//
//  AppDelegate.m
//  PhotoTake
//
//  Created by Xinyu Liang on 16/10/3.
//  Copyright © 2016年 Xinyu Liang. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Create.h"
#import "PhotoDatabaseAvailability.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
@interface AppDelegate () <NSURLSessionDelegate>

@property(copy,nonatomic)void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property(nonatomic,strong)NSManagedObjectContext * context;
@property(nonatomic,strong)NSTimer* timer;
@property(nonatomic,strong)NSURLSession* session;

@end


@implementation AppDelegate


#pragma mark -definations

        #define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

        #define BACKGROUND_FLICKR_FETCH_TIMEOUT 10

        #define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

#pragma mark -initWithContextAndFetch

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    

    
    self.context=[self createManagedObjectContext];//此时依然什么也都没有，需要下东西到context中
    [self startFetch];
    
    return YES;
}
#pragma mark - context

-(void)setContext:(NSManagedObjectContext *)context
{
    _context=context;
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer=[NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                target:self
                                              selector:@selector(startFetch:)// 必须带有参数：(NSTimer*)timer
                                              userInfo:nil
                                               repeats:YES];
    NSDictionary* dictionary=self.context?@{PhotoDatabaseAvailabilityContext:self.context}:nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:nil
                                                      userInfo:dictionary];
    
}

#pragma mark - fetch 

-(void)startFetch:(NSTimer *) timer
{
    [self startFetch];
}

-(void)startFetch{
    
    [self.session getTasksWithCompletionHandler:^(NSArray * dataTasks, NSArray* uploadTasks, NSArray* downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask* task=[self.session downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription=FLICKR_FETCH;
            [task resume];
        }else
        {
            for(NSURLSessionDownloadTask * downloadTask in downloadTasks)
            {
            
                [downloadTask resume];
            }
        }
    }];
    
}

-(NSURLSession *)session
{
    if (!_session) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            NSURLSessionConfiguration* configuration=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            _session=[NSURLSession sessionWithConfiguration:configuration
                                                   delegate:self
                                              delegateQueue:nil];
        });
    }
    return _session;
}



#pragma mark- occionally fetch

-(void)application:(UIApplication*)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler
{
    self.flickrDownloadBackgroundURLSessionCompletionHandler=completionHandler;
}


-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.context) {
        NSURLSessionConfiguration* configuration=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.allowsCellularAccess=NO;
        configuration.timeoutIntervalForRequest=BACKGROUND_FLICKR_FETCH_TIMEOUT;
        NSURLSession* session=[NSURLSession sessionWithConfiguration:configuration];
        
        NSURLRequest* request=[NSURLRequest requestWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultNoData);
                                                            } else {
                                                                [self loadFlickrPhotosFromLocalURL:localFile
                                                                                       intoContext:self.context
                                                                               andThenExecuteBlock:^{
                                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                                               }
                                                                 ];
                                                            }
                                                        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }
}

#pragma mark- fetchSuccessful

-(void)loadFlickrPhotosFromLocalURL:(NSURL*)localFile intoContext:(NSManagedObjectContext*)context andThenExecuteBlock:(void(^)())whenDone
{
    NSArray* array=[self flickrPhotosAtURL:localFile];
    
    if (array)
    {
         [context performBlock:^
         {
             [Photo loadPhotosFromFlickrArray:array inManagedObjectContext:self.context];
             NSError* error;
#warning I think this will also call setContext too!!!!
             [context save:&error];
         }];
    }
    if (whenDone) {
        whenDone();// 这样就不会报错
    }
    
}
- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}


#pragma mark -applicationDelegate

- (void)applicationWillResignActive:(UIApplication *)application {
    [self saveContext];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error;
    if (self.context != nil) {
        if ([self.context hasChanges] && ![self.context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - SessionDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        // ... but if this is the Flickr fetching, then process the returned data
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.context
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }
         ];
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
  }

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.session)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

// this is "might" in case some day we have multiple downloads going on at once

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}

@end
