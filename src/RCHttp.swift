//
//  RCHttp.swift
//  Photography Places
//
//  Created by Baluta Cristian on 08/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import UIKit

class RCHttp: NSObject {
	
	var url :String?;
	var task :NSURLSessionTask?;
	
	convenience init (_ baseURL:NSString, endpoint:NSString?) {
		self.init()
		let separator = endpoint? != nil ? "/" : ""
		let end = endpoint? != nil ? endpoint? : ""
		url = String("\(baseURL)\(separator)\(end!)")
	}
	
	
	//pragma mark post data sync and async

	func post (dictionary:Dictionary<String,AnyObject>, completion:NSDictionary -> Void, errorHandler:NSDictionary -> Void) {
	
		var postStr :NSString = "";
		for (key, vale) in dictionary {
			postStr = "\(postStr)\(key)=\(vale)&";
		}
		
		var postData :NSData = postStr.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!;
		var postLength = String (postData.length);
		
		let request = NSMutableURLRequest()
		request.URL = NSURL(string:url!)
		request.HTTPMethod = "POST"
		request.setValue(postLength, forHTTPHeaderField:"Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
		request.HTTPBody = postData;
		
		var session = NSURLSession( configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration());
		task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			
			// notice that I can omit the types of data, response and error
			
//			RCLogO( NSString(data:data, encoding: 0));

			if (error == nil) {
				var json :NSDictionary? = nil;
				var e :NSError? = nil
				var response_dict = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments, error:&e) as NSDictionary?
				
				if (e != nil) {
					json = ["text":"Json parse error"]
				} else {
					json = response_dict as NSDictionary?
				}
				completion(json!)
			}
			else {
				errorHandler(["text":"Download error"])
			}
		})
		task?.resume()
	}
	
	func upload (data:NSData, filename:String, completion:NSDictionary -> Void, error:NSDictionary -> Void) {
		
		var request :NSMutableURLRequest = NSMutableURLRequest();
		request.URL = NSURL(string:url!);
		request.HTTPMethod = "POST";
//		request.setValue(postLength, forHTTPHeaderField:"Content-Length");
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
//		request.HTTPBody = postData;
		
		var session = NSURLSession( configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration());
		task = session.uploadTaskWithRequest(request, fromData: data, completionHandler: { (data_, response_, error_) -> Void in
			var json :NSDictionary? = nil;
			
			if (error_ != nil) {
				var e :NSErrorPointer? = nil;
				var response_dict :AnyObject? = NSJSONSerialization.JSONObjectWithData(data_, options:NSJSONReadingOptions.AllowFragments, error:e!);
				//				println(response_dict);
				if (e! == nil) {
					json = ["text":"Json parse error"];
				}
				else {
					json = response_dict as? NSDictionary;
				}
				completion(json!);
			}
			error(["text":"Dwnlad error"]);
		})
		task?.resume()
	}
	
	func cancel () {
		task?.cancel()
	}
	
	/*
	
	//pragma mark post data with attachment, sync and async
	
	- (NSDictionary*)postData:(NSData*)data withName:(NSString*)filename {
	
	// Setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:URL]];
	[request setHTTPMethod:@"POST"];
	
	// We always need a boundary when we post a file
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	// Now lets create the body of the post
	NSString *bound1 = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
	NSString *bound2 = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
	NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadFile\"; filename=\"%@\"\r\n", filename];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[bound1 dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:data]];
	[body appendData:[bound2 dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
	
	// Upload
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *response_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (!error) {
	NSDictionary *response_dict = [NSJSONSerialization JSONObjectWithData:response_data options:NSJSONReadingAllowFragments error:&error];
	if (error) {
	return @{@"text":@"Json parse error"};
	}
	else {
	return response_dict;
	}
	}
	else {
	return nil;
	}
	return nil;
	}
	
	*/
	
	func downloadStarted () {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
	}
	
	func downloadEnded () {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
	}
}
