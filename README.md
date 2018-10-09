RCHttp
=====

Easy lib  to  do http requests:

Usage
=====

Add the RCLog classes to your project then import it once in the .pch file

    let http = RCHttp(baseUrl: "base_url")
    
    // If you need authentication:
    http.authenticate(user: "user", password: "password")
    
    // Do requests with get/put/post
    http.get(at: "path", success: { result in }, failure: { error in })
    http.post(at: "path", parameters: [:], success: { result in }, failure: { error in })
    http.put(at: "path", parameters: [:], success: { result in }, failure: { error in })
