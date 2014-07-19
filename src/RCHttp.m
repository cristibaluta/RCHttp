//
//  RCHttp.m
//  IMAGIN
//
//  Created by Baluta Cristian on 5/9/10.
//  Copyright 2010 ralcr. All rights reserved.
//

#import "RCHttp.h"


@implementation RCHttp


- (id)initWithURL:(NSString*)u delegate:(id)d {
	
	if (self = [super init]) {
		_URL = u;
		delegate = d;
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (id)initWithBaseURL:(NSString*)u endpoint:(NSString*)endpoint {
	
	if (self = [super init]) {
		_URL = [NSString stringWithFormat:@"%@%@%@", u, endpoint ? @"/" : @"", endpoint ? endpoint : @""];
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}


#pragma mark Async methods to make the request and receive progress notifications

- (void)start {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_URL]];
    [self download:request];
}

- (void)cancel {
	[connection cancel];
	connection = nil;
}

- (void)post:(NSDictionary*)dictionary {
	
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
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
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
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
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


#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	_receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	
	// Called when a chunk of data has been downloaded.
	
	[_receivedData appendData:data];
	
	[self performSelectorOnMainThread:@selector(onRCHttpProgress) withObject:nil waitUntilDone:NO];
}

/*- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse;
{
    NSLog(@"redirectResponse %@", inRedirectResponse);
	return inRequest;
//	if (inRedirectResponse) {
//        NSMutableURLRequest *r = [[request mutableCopy] autorelease]; // original request
//        [r setURL: [inRequest URL]];
//        return r;
//    } else {
//        return inRequest;
//    }
}*/

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    
    _result = [[NSString alloc] initWithData:_receivedData encoding:NSASCIIStringEncoding];
	
	[self performSelectorOnMainThread:@selector(onRCHttpComplete) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    
	if ([error code] == kCFURLErrorNotConnectedToInternet) {
        [self performSelectorOnMainThread:@selector(onHTTPConnectionError) withObject:nil waitUntilDone:NO];
    }
	else {
        [self performSelectorOnMainThread:@selector(onRCHttpError) withObject:nil waitUntilDone:NO];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	// Disable caching so that each time we run this app we are starting with a clean slate.
    return nil;
}


#pragma mark Delegate stuff

- (void) onRCHttpProgress {
	if ([delegate respondsToSelector:@selector(onRCHttpProgress:)])
		[delegate performSelector:@selector(onRCHttpProgress:) withObject:self];
}

- (void) onRCHttpComplete {
	if ([delegate respondsToSelector:@selector(onRCHttpComplete:)])
		[delegate performSelector:@selector(onRCHttpComplete:) withObject:self];
}

- (void) onRCHttpError {
	if ([delegate respondsToSelector:@selector(onRCHttpError:)])
		[delegate performSelector:@selector(onRCHttpError:) withObject:self];
}

- (void) onHTTPConnectionError {
	if ([delegate respondsToSelector:@selector(onHTTPConnectionError)])
		[delegate performSelector:@selector(onHTTPConnectionError)];
}


#pragma mark Network indicator

- (void) downloadStarted {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) downloadEnded {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
