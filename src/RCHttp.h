//
//  LoadAndParseXml.h
//  IMAGIN
//
//  Created by Baluta Cristian on 5/9/10.
//  Copyright 2010 ralcr. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>

@protocol RCHttpDelegate;
@interface RCHttp : NSObject {
	
	id<RCHttpDelegate> delegate;
	NSURLConnection *connection;
	NSOperationQueue *queue;
}

@property (nonatomic, strong) NSString *URL;
@property (nonatomic, readonly) NSString *result;
@property (nonatomic, readonly) NSMutableData *receivedData;

- (id)initWithURL:(NSString*)u delegate:(id<RCHttpDelegate>)d;
- (id)initWithBaseURL:(NSString*)u endpoint:(NSString*)endpoint;

- (void)start;
- (void)cancel;
- (void)post:(NSDictionary*)dict;
- (void)post:(NSDictionary*)dict completion:(void(^)(NSDictionary *dict))block error:(void(^)())error_block;
- (void)get:(NSString*)url completion:(void(^)(NSData *data))block error:(void(^)())error_block;

- (void)download:(NSURLRequest *)request;

@end


@protocol RCHttpDelegate <NSObject>

@optional
- (void)onRCHttpProgress:(RCHttp*)request;
- (void)onRCHttpComplete:(RCHttp*)request;
- (void)onRCHttpError:(RCHttp*)request;
- (void)onHTTPConnectionError;

@end

