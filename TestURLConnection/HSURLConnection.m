//
//  HSURLConnection.m
//  Loverly
//
//  Created by Sai Tat Lam on 15/02/13.
//  Copyright (c) 2013 Henshin Soft. All rights reserved.
//

#import "HSURLConnection.h"

#define SHARED_INSTANCE ((HSURLConnection *)[HSURLConnection sharedInstance])

@interface HSURLConnection () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary *connections;
@property (nonatomic, strong) NSMutableDictionary *downloadBlocks;
@property (nonatomic, strong) NSMutableDictionary *uploadBlocks;
@property (nonatomic, strong) NSMutableDictionary *completionBlocks;
@property (nonatomic, strong) NSMutableDictionary *errorBlocks;
@property (nonatomic, strong) NSMutableDictionary *datas;
@property (nonatomic, strong) NSMutableDictionary *responses;
@property (nonatomic, strong) NSMutableDictionary *requests;
@property (nonatomic, strong) NSMutableDictionary *downloadSizes;

@end

static HSURLConnection *sharedInstance__;

@implementation HSURLConnection

+ (id)sharedInstance {
  if (sharedInstance__ == nil) {
    sharedInstance__ = [[HSURLConnection alloc] init];
  }
  
  return sharedInstance__;
}

- (id)init
{
  self = [super init];
  
  if (self) {
    self.connections = [NSMutableDictionary dictionary];
    self.downloadBlocks = [NSMutableDictionary dictionary];
    self.uploadBlocks = [NSMutableDictionary dictionary];
    self.completionBlocks = [NSMutableDictionary dictionary];
    self.errorBlocks = [NSMutableDictionary dictionary];
    self.datas = [NSMutableDictionary dictionary];
    self.requests = [NSMutableDictionary dictionary];
    self.responses = [NSMutableDictionary dictionary];
    self.downloadSizes = [NSMutableDictionary dictionary];
  }
  
  return self;
}

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(HSURLConnectionErrorBlock)errorBlock
               uploadPorgressBlock:(HSURLConnectionUploadProgressBlock)uploadBlock
             downloadProgressBlock:(HSURLConnectionDownloadProgressBlock)downloadBlock
{
  NSString *key = [request.URL.absoluteString copy];
  
  // If a connection is already happening, we just overwrite the blocks.
  if ([SHARED_INSTANCE.connections objectForKey:key]) {
    if (completionBlock) {
      [SHARED_INSTANCE.completionBlocks setObject:[completionBlock copy] forKey:key];
    } else {
      [SHARED_INSTANCE.completionBlocks removeObjectForKey:key];
    }
    if (errorBlock) {
      [SHARED_INSTANCE.errorBlocks setObject:[errorBlock copy] forKey:key];
    } else {
      [SHARED_INSTANCE.errorBlocks removeObjectForKey:key];
    }
    if (downloadBlock) {
      [SHARED_INSTANCE.downloadBlocks setObject:[downloadBlock copy] forKey:key];
    } else {
      [SHARED_INSTANCE.downloadBlocks removeObjectForKey:key];
    }
    if (uploadBlock) {
      [SHARED_INSTANCE.uploadBlocks setObject:[uploadBlock copy] forKey:key];
    } else {
      [SHARED_INSTANCE.uploadBlocks removeObjectForKey:key];
    }
    return;
  }
  
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:SHARED_INSTANCE startImmediately:NO];
  [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  
  // Setup connection prerequisites.
  [SHARED_INSTANCE.connections setObject:connection  forKey:key];
  [SHARED_INSTANCE.requests setObject:request forKey:key];
  if (completionBlock) {
    [SHARED_INSTANCE.completionBlocks setObject:[completionBlock copy] forKey:key];
  }
  if (errorBlock) {
    [SHARED_INSTANCE.errorBlocks setObject:[errorBlock copy] forKey:key];
  }
  if (downloadBlock) {
    [SHARED_INSTANCE.downloadBlocks setObject:[downloadBlock copy] forKey:key];
  }
  if (uploadBlock) {
    [SHARED_INSTANCE.uploadBlocks setObject:[uploadBlock copy] forKey:key];
  }
  [connection start];
}

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request
                   completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                        errorBlock:(HSURLConnectionErrorBlock)errorBlock
{
  [HSURLConnection asyncConnectionWithRequest:request
                              completionBlock:completionBlock
                                   errorBlock:errorBlock
                          uploadPorgressBlock:nil
                        downloadProgressBlock:nil];
}

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(HSURLConnectionCompletionBlock)completionBlock
                          errorBlock:(HSURLConnectionErrorBlock)errorBlock
{
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  
  [HSURLConnection asyncConnectionWithRequest:request
                              completionBlock:completionBlock
                                   errorBlock:errorBlock];
}

- (void)cleanUpForConnection:(NSURLConnection *)connection
{
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    
    [self.connections removeObjectForKey:key];
    [self.requests removeObjectForKey:key];
    [self.responses removeObjectForKey:key];
    [self.datas removeObjectForKey:key];
    [self.completionBlocks removeObjectForKey:key];
    [self.errorBlocks removeObjectForKey:key];
    [self.downloadBlocks removeObjectForKey:key];
    [self.uploadBlocks removeObjectForKey:key];
    [self.downloadSizes removeObjectForKey:key];
  }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    HSURLConnectionErrorBlock errorBlock = self.errorBlocks[key];
    if (errorBlock) errorBlock(error);
  }
  
  [SHARED_INSTANCE cleanUpForConnection:connection];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    HSURLConnectionCompletionBlock completionBlock = self.completionBlocks[key];
    NSData *data = self.datas[key];
    id response = self.responses[key];
    if (completionBlock) completionBlock(data, response);
  }
  
  [SHARED_INSTANCE cleanUpForConnection:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    [self.responses setObject:response forKey:key];
    [self.downloadSizes setObject:[NSNumber numberWithLongLong:response.expectedContentLength] forKey:key];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    NSMutableData *data = (id)self.datas[key];
    
    if (data == nil) {
      data = [[NSMutableData alloc] init];
    }
    
    [data appendData:theData];
    
    [self.datas setObject:data forKey:key];
    
    NSNumber *downloadSize = (NSNumber *)self.downloadSizes[key];
    HSURLConnectionDownloadProgressBlock downloadBlock = self.downloadBlocks[key];
    if (downloadSize.longLongValue != -1) {
      float progress = (float)data.length / (float)(downloadSize.longLongValue);
      
      if(downloadBlock) downloadBlock(progress);
    }
  }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
  float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
  NSArray *keys = [self.connections allKeysForObject:connection];
  
  for (NSString *key in keys) {
    HSURLConnectionUploadProgressBlock uploadBlock = self.uploadBlocks[key];
    if (uploadBlock) uploadBlock(progress);
  }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
  return nil;
}

@end
