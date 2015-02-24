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

- (void)POST:(NSDictionary *)dict completion:(void(^)(NSDictionary *dict))completionBlock error:(void(^)())errorBlock;
- (void)UPLOAD:(NSDictionary *)dict completion:(void(^)(NSDictionary *dict))completionBlock error:(void(^)())errorBlock;
- (void)GET:(NSString *)url completion:(void(^)(NSData *data))block error:(void(^)())error_block;

- (void)cancel;

@end
