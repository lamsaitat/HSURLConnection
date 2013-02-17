//
//  TASAppDelegate.h
//  TestURLConnection
//
//  Created by Sai Tat Lam on 15/02/13.
//  Copyright (c) 2013 Sai Tat Lam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TASViewController;
@class LLURLConnection;

@interface TASAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TASViewController *viewController;

@property (strong, nonatomic) LLURLConnection *connection;

@end
