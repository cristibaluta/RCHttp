//
//  RCHttp.h
//
//
//  Created by Baluta Cristian on 5/9/10.
//  Copyright 2015 ralcr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHttp : NSObject

- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithBaseUrl:(NSString *)url endpoint:(NSString *)endpoint;

- (void)post:(NSDictionary *)dictionary
  completion:(void (^)(NSDictionary *))completionBlock
	   error:(void (^)())errorBlock;

- (void)upload:(NSData *)data
	  withName:(NSString *)filename
	completion:(void (^)(NSDictionary *))completionBlock
		 error:(void (^)())errorBlock;

- (void)cancel;

@end
