//
//  HSURLConnection.h
//
//
//  Created by Sai Tat Lam on 15/02/13.
//  Copyright (c) 2013 Henshin Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HSURLConnectionCompletionBlock)          (NSData *data, NSURLResponse *response);
typedef void (^HSURLConnectionErrorBlock)               (NSError *error);
typedef void (^HSURLConnectionUploadProgressBlock)      (float progress);
typedef void (^HSURLConnectionDownloadProgressBlock)    (float progress);

@interface HSURLConnection : NSObject

+ (id)sharedInstance;

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(HSURLConnectionErrorBlock)errorBlock
               uploadPorgressBlock:(HSURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(HSURLConnectionDownloadProgressBlock)downloadBlock;

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(HSURLConnectionErrorBlock)errorBlock;

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                          errorBlock:(HSURLConnectionErrorBlock)errorBlock;

@end
