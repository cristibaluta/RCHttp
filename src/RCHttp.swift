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
		let separator = endpoint != nil ? "/" : ""
		let end = endpoint != nil ? endpoint : ""
		url = String("\(baseURL)\(separator)\(end!)")
	}
	
	
	//pragma mark post data sync and async

	func post (dictionary:Dictionary<String,AnyObject>, completion:NSDictionary -> Void, errorHandler:NSDictionary -> Void) {
	
		var postStr :NSString = "";
		for (key, vale) in dictionary {
			postStr = "\(postStr)\(key)=\(vale)&";
		}
		
		let postData :NSData = postStr.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion:true)!;
		let postLength = String (postData.length);
		
		let request = NSMutableURLRequest()
		request.URL = NSURL(string:url!)
		request.HTTPMethod = "POST"
		request.setValue(postLength, forHTTPHeaderField:"Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
		request.HTTPBody = postData;
		
		let session = NSURLSession( configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration());
		task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			
			// notice that I can omit the types of data, response and error
			
//			RCLogO( NSString(data:data, encoding: 0));

			if (error == nil) {
				var json: NSDictionary = ["text":"Json parse error"]
				if let d = try? NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments) {
					json = d as! NSDictionary
				}
				completion(json)
			}
			else {
				errorHandler(["text":"Download error"])
			}
		})
		task?.resume()
	}
	
	func upload (data:NSData, filename:String, completion:NSDictionary -> Void, error:NSDictionary -> Void) {
		
		let request :NSMutableURLRequest = NSMutableURLRequest();
		request.URL = NSURL(string:url!);
		request.HTTPMethod = "POST";
//		request.setValue(postLength, forHTTPHeaderField:"Content-Length");
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
//		request.HTTPBody = postData;
		
		let session = NSURLSession( configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration());
		task = session.uploadTaskWithRequest(request, fromData: data, completionHandler: { (data_, response_, error_) -> Void in
			var json :NSDictionary? = nil;
			
			if (error_ != nil) {
				let e: NSErrorPointer? = nil;
				var response_dict :AnyObject?
				do {
					response_dict = try NSJSONSerialization.JSONObjectWithData(data_!, options:NSJSONReadingOptions.AllowFragments)
				} catch let error as NSError {
					e!.memory = error
					response_dict = nil
				} catch {
					fatalError()
				};
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
	
	func downloadStarted () {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
	}
	
	func downloadEnded () {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
	}
}
