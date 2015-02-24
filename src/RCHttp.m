//
//  RCHttp.m
//  IMAGIN
//
//  Created by Baluta Cristian on 5/9/10.
//  Copyright 2010 ralcr. All rights reserved.
//

#import "RCHttp.h"

@interface RCHttp () <NSURLSessionDelegate> {
	
	
	NSURLSession *_session;
}

@end

static int _activeRequests = 0;

@implementation RCHttp

- (instancetype)initWithUrl:(NSString *)url {
	
	if (self = [super init]) {
		
	}
	return self;
}

- (instancetype)initWithBaseUrl:(NSString *)url endpoint:(NSString *)endpoint {
	
	if (self = [super init]) {
		_URL = [NSString stringWithFormat:@"%@%@%@", u, endpoint ? @"/" : @"", endpoint ? endpoint : @""];
	}
	return self;
}


#pragma mark Async methods to make the request and receive progress notifications

- (void)start {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_URL]];
    [self download:request];
}

- (void)cancel {
	[_session ];
}

- (void)POST:(NSDictionary *)dict completion:(void (^)(NSDictionary *))completionBlock error:(void (^)())errorBlock {
	
	// Create POST variables
	NSMutableString *postStr = [[NSMutableString alloc] init];
	
	for (id key in dictionary) {
		//NSLog(@"RCHttp append key: %@, value: %@", key, [dictionary objectForKey:key]);
		[postStr appendFormat:@"%@=%@&", key, [dictionary objectForKey:key]];
	}
	
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	//NSLog(@"RCHttp scriptsPath: %@", scriptsPath);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	[self download:request];
}

- (void)download:(NSURLRequest *)request {
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSAssert (connection != nil, @"Failure to create URL connection.");
}


#pragma mark Block methods. This cannot return progress notifications

- (void)post:(NSDictionary*)dictionary completion:(void(^)(NSDictionary *dict))block error:(void(^)())error_block {
	
	// Create POST variables
	NSMutableString *postStr = [[NSMutableString alloc] init];
	
	for (id key in dictionary) {
		[postStr appendFormat:@"%@=%@&", key, [dictionary objectForKey:key]];
	}
	
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *err) {
		
		if (!err) {
			NSError *err2 = nil;
			NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err2];
			if (err2) {
				block(@{@"text":@"Json parse error"});
			}
			else {
				block(responseDict);
			}
		}
		else {
			error_block();
		}
	}];
}

- (void)get:(NSString*)url completion:(void(^)(NSData *data))block error:(void(^)())error_block {
	
}


#pragma mark Network indicator

- (void) downloadStarted {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) downloadEnded {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
