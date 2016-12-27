//
//  CGEHelpers.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import Firebase

extension CGEClient {
  func constructURL(path: String, queryString: [String:Any]?) -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = CGEConstants.host
    urlComponents.port = CGEConstants.port
    urlComponents.path = path
    urlComponents.queryItems = []
    
    if let queryString = queryString {
      for (key, value) in queryString {
        urlComponents.queryItems?.append(URLQueryItem(name: key, value: "\(value)"))
      }
    }
    
    return urlComponents.url
  }
  
  func createRequest(method: HTTPMethods, path: String, queryString: [String:Any]?, jsonBody: [String:Any]?,
                     completionHandler: @escaping (URLRequest?, Error?) -> Void) {
    guard let url = constructURL(path: path, queryString: queryString) else {
      let userInfo = [NSLocalizedDescriptionKey: "Error while constructing url for \(path) with query \(queryString)"]
      completionHandler(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: userInfo))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    if let jsonBody = jsonBody {
      request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
      request.addValue(HeaderValues.contentTypeJSON, forHTTPHeaderField: HeaderKeys.contentType)
    }
    
    guard let currentUser = FIRAuth.auth()?.currentUser else {
      let userInfo = [NSLocalizedDescriptionKey: "No user logged in. Please login and continue"]
      completionHandler(nil, NSError(domain: FIRAuthErrorDomain, code: FIRAuthErrorCode.errorCodeUserNotFound.rawValue, userInfo: userInfo))
      return
    }
    
    currentUser.getTokenWithCompletion() {
      token, error in
      
      guard let token = token, error == nil else {
        completionHandler(nil, error)
        return
      }
      
      request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderKeys.authorization)
      
      completionHandler(request, nil)
    }
  }
  
  func runDataTask(with request: URLRequest, completionHandler: @escaping (Any?, Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: request) {
      data, response, error in
      
      self.processResponse(data: data, response: response, error: error, completionHandler: completionHandler)
    }
    
    task.resume()
  }
  
  func processResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: (Any?, Error?) -> Void) {
    guard let data = data, error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode else {
      completionHandler(nil, error)
      return
    }
    
    guard statusCode >= 200 && statusCode <= 299 else {
      
      var errorDescription = "Error while executing request."
      var code = ErrorCode.unknown
      
      if statusCode == 401 {
        errorDescription = "Invalid or expired token."
        code = ErrorCode.authenticationFailed
      } else if statusCode == 400 {
        errorDescription = "Invalid URL Request. \(response!.url)"
        code = ErrorCode.invalidRequest
      } else if statusCode == 404 {
        errorDescription = "No resource exists for url \(response!.url)"
        code = ErrorCode.notFound
      }
      
      let userInfo = [NSLocalizedDescriptionKey: errorDescription]
      completionHandler(nil, NSError(domain: cgeErrorDomain, code: code.rawValue, userInfo: userInfo))
      
      return
    }
    
    guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
      let userInfo = [NSLocalizedDescriptionKey: "Error while parsing json"]
      completionHandler(nil, NSError(domain: cgeErrorDomain, code: ErrorCode.invalidJSON.rawValue,
                                     userInfo: userInfo))
      return
    }
    
    completionHandler(jsonData, nil)
  }
  
  func replace(placeholder: String, in path: String, with text: String) -> String {
    guard let range = path.range(of: placeholder) else {
      return path
    }
    
    return path.replacingCharacters(in: range, with: text)
  }
}
