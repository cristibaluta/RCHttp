//
//  RCHttp.m
//  IMAGIN
//
//  Created by Baluta Cristian on 5/9/10.
//  Copyright 2010 ralcr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHttp.h"

@interface RCHttp () <NSURLSessionDelegate> {
	
	NSURL *_URL;
	NSURLSessionDataTask *_task;
}

@end

//static int _activeRequests = 0;

@implementation RCHttp

- (instancetype)initWithUrl:(NSString *)url {
	
	if (self = [super init]) {
		_URL = [NSURL URLWithString:url];
	}
	return self;
}

- (instancetype)initWithBaseUrl:(NSString *)url endpoint:(NSString *)endpoint {
	
	if (self = [super init]) {
		_URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", url, endpoint ? @"/" : @"", endpoint ? endpoint : @""]];
	}
	return self;
}

- (void)post:(NSDictionary *)dictionary
  completion:(void (^)(NSDictionary *))completionBlock
	   error:(void (^)())errorBlock {
	
	// Create POST variables
	NSMutableString *postStr = [[NSMutableString alloc] init];
	
	for (id key in dictionary) {
		[postStr appendFormat:@"%@=%@&", key, [dictionary objectForKey:key]];
	}
	
    NSData *postData = [postStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:_URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	_task = [[NSURLSession sharedSession] dataTaskWithRequest:request
											completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			errorBlock();
		}
		else {
			NSError *err2 = nil;
			NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err2];
			if (err2) {
				completionBlock(@{@"text":@"Json parse error"});
			}
			else {
				completionBlock(responseDict);
			}
		}
		[self downloadEnded];
	}];
	[_task resume];
	[self downloadStarted];
}

- (void)upload:(NSData *)data
	  withName:(NSString *)filename
	completion:(void (^)(NSDictionary *))completionBlock
		 error:(void (^)())errorBlock {

	// Setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:_URL];
	[request setHTTPMethod:@"POST"];
	
	// We always need a boundary when we post a file
//	NSString *boundary = @"---------------------------14737809831466499882746641449";
//	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
//	
//	// Now lets create the body of the post
//	NSString *bound1 = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
//	NSString *bound2 = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
//	NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadFile\"; filename=\"%@\"\r\n", filename];
//	
//	NSMutableData *body = [NSMutableData data];
//	[body appendData:[bound1 dataUsingEncoding:NSUTF8StringEncoding]];
//	[body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
//	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//	[body appendData:[NSData dataWithData:data]];
//	[body appendData:[bound2 dataUsingEncoding:NSUTF8StringEncoding]];
//	
//	[request setHTTPBody:body];
	
	_task = [[NSURLSession sharedSession] uploadTaskWithRequest:request
													   fromData:data
											  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		
												  if (!error) {
													  NSError *jerror = nil;
													  NSDictionary *response_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jerror];
													  if (jerror) {
														  completionBlock(@{@"text":@"Json parse error"});
													  }
													  else {
														  completionBlock(response_dict);
													  }
												  }
												  else {
													  errorBlock();
												  }
												  [self downloadEnded];
											  }];
	[_task resume];
	[self downloadStarted];
}

- (void)cancel {
	[_task cancel];
}


#pragma mark Network indicator

- (void)downloadStarted {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
	[[NSURLSession sharedSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		if (dataTasks.count == 0 && uploadTasks.count == 0 && downloadTasks.count == 0) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
	}];
}

@end
