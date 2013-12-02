//
//  PVViewController.h
//  LavenderBearWatcher
//
//  Created by SheltonHan on 19/11/13.
//  Copyright (c) 2013 BoxOfCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVViewController : UIViewController<UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *pageWebView;

@property (retain, nonatomic) IBOutlet UILabel *pageSearchResult;
@property (retain, nonatomic) IBOutlet UILabel *pageLoadFinishDateTextView;

@property (retain, nonatomic) IBOutlet UITextView *pageSourceTextView;

@property (retain, nonatomic) IBOutlet UIButton *refreshButton;

@property (nonatomic, retain) NSString* bearURLString;
@property (nonatomic, retain) NSDate* loadFinishTime;
@property (nonatomic, retain) NSDate* notificationTime;

@property (nonatomic, retain) NSMutableArray* blockList;
@property (nonatomic) Boolean isRemoteCalledToNotify;

- (void) notificationWithMessage:(NSString*)argMessage;

- (void) loadBearPageWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
- (void) loadBearPage;

@end
