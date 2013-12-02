//
//  PVViewController.m
//  LavenderBearWatcher
//
//  Created by SheltonHan on 19/11/13.
//  Copyright (c) 2013 BoxOfCats. All rights reserved.
//

#import "PVViewController.h"

@interface PVViewController (private)
{


}

@end

@implementation PVViewController
@synthesize pageWebView, pageSearchResult, pageLoadFinishDateTextView, pageSourceTextView, refreshButton, loadFinishTime, notificationTime, blockList;
@synthesize bearURLString, isRemoteCalledToNotify;



- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    [self setBearURLString:@"http://bridestowelavender.com.au/pub/index.php?c=19&products=3&details=126&backStr=Return%20to%20Site&backurl=c%3D19"];
    
    //testing - sold out
    //[self setBearURLString:@"http://hanxt90.wordpress.com/2013/12/01/testingtext/"];
    
    //testing - sold out
//    [self setBearURLString:@"http://hanxt90.wordpress.com/2013/12/01/testingtext-available/"];
    
    
    self.isRemoteCalledToNotify = false;
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self loadBearPage];
    
    [NSTimer scheduledTimerWithTimeInterval:(1 * 60 * 10) target:self selector:@selector(loadBearPage) userInfo:NULL repeats:true];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    pageWebView.delegate = nil;
}


- (IBAction)onRefreshButton:(id)sender
{
//    [self notificationWithMessage:@"notification: refresh"];
    [self loadBearPage];

}


- (void) loadBearPageWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
//    [self notificationWithMessage:@"loadBearPageWithCompletionHandler called"];
    self.isRemoteCalledToNotify = true;
    [self.blockList addObject:completionHandler];
    [self loadBearPage];
    
}

- (void) loadBearPage
{

    if ([pageWebView isLoading])
    {
        [pageWebView stopLoading];
    }
    [pageWebView setDelegate: self];
    NSURL* bearURL = [NSURL URLWithString:self.bearURLString];
    NSURLRequest* bearRequest = [NSURLRequest requestWithURL:bearURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
    [pageWebView loadRequest:bearRequest];
    

}

//UIWebview delagate method
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    if (html != nil && [html length] > 0)
    {
        [self setupHTMLString:html];
    }
    
    NSLog(@"bear webViewDidFinishLoad called");
}

- (void) setupHTMLString:(NSString*) argHtml
{
    [pageSourceTextView setText:argHtml];
    NSRange range = [argHtml rangeOfString:@"Sold out"];
    if (range.location != NSNotFound)
    {
        [pageSearchResult setText:@"bear Sold out"];
        //SH - testing
//        [self notifyUserIfNeeded:false];
    }
    else
    {
        [pageSearchResult setText:@"bear stock available"];
        //TODO SH - add notification logic
        [self notifyUserIfNeeded:true];
        
    }
    self.loadFinishTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [pageLoadFinishDateTextView setText:[dateFormatter stringFromDate:self.loadFinishTime]];
    
    

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"bear didFailLoadWithError called");
}


- (void) notifyUserIfNeeded:(Boolean)isStockAvailable
{
    NSString* notificationBody = @"";
    if (isStockAvailable)
    {
        notificationBody = @"Bridestowe Lavender Bear available now";
    }
    else
    {
        notificationBody = @"Bridestowe Lavender Bear Sold out";
    }
    
    NSInteger currentBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if (self.isRemoteCalledToNotify && currentBadgeNumber < 1)
    {
        self.isRemoteCalledToNotify = false;
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeInterval:1 sinceDate:[NSDate date]];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = notificationBody;
        localNotification.alertAction = @"View";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    }
    
    if (self.blockList != NULL && self.blockList.count > 0)
    {
        void (^completionHandler)(UIBackgroundFetchResult result) = [self.blockList objectAtIndex:0];
        completionHandler(UIBackgroundFetchResultNewData);
        [self.blockList removeAllObjects];
    }

}

- (void) notificationWithMessage:(NSString*)argMessage
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeInterval:5 sinceDate:[NSDate date]];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = argMessage;
    localNotification.alertAction = @"View";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
