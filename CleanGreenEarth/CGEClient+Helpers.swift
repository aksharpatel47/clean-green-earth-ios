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
  
  func createUploadRequest(method: HTTPMethods, path: String, files: [CGEFile], mpData: [String:String]?, completionHandler: @escaping (URLRequest?, Error?) -> Void) {
    guard let url = constructURL(path: path, queryString: nil) else {
      let userInfo = [NSLocalizedDescriptionKey: "Error while constructing url for \(path)"]
      completionHandler(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: userInfo))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    let boundary = "Boundary-\(UUID().uuidString)"
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
    
    var data = Data()
    
    for file in files {
      data.append("--\(boundary)".data(using: .utf8)!)
      data.append("Content-Disposition:form-data; name =\"\(file.name)\"; filename=\"\(file.name).jpg\"\r\n".data(using: .utf8)!)
      data.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8)!)
      data.append(file.data)
      data.append("\r\n".data(using: .utf8)!)
    }
    
    if let mpData = mpData {
      for (key, value) in mpData {
        data.append("--\(boundary)".data(using: .utf8)!)
        data.append("Content-Disposition:form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(value)\r\n".data(using: .utf8)!)
      }
    }
    
    data.append("--\(boundary)--".data(using: .utf8)!)
    
    request.httpBody = data
    
    if let currentUser = FIRAuth.auth()?.currentUser {
      currentUser.getTokenWithCompletion() {
        token, error in
        
        guard let token = token, error == nil else {
          completionHandler(nil, error)
          return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        completionHandler(request, nil)
      }
    } else {
      let authenticationError = NSError(domain: CGEClient.errorDomain, code: CGEClient.ErrorCode.authenticationFailed.rawValue, userInfo: nil)
      completionHandler(nil, authenticationError)
    }
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
    
    if let currentUser = FIRAuth.auth()?.currentUser {
      currentUser.getTokenWithCompletion() {
        token, error in
        
        guard let token = token, error == nil else {
          completionHandler(nil, error)
          return
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: HeaderKeys.authorization)
        
        completionHandler(request, nil)
      }
    } else {
      completionHandler(nil, NSError(domain: CGEClient.errorDomain, code: ErrorCode.authenticationFailed.rawValue, userInfo: nil))
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
        errorDescription = "Error while processing request. \(response!.url)"
        code = ErrorCode.generalError
      } else if statusCode == 422 {
        errorDescription = "Invalid URL Request. \(response!.url)"
        code = ErrorCode.malformedRequest
      } else if statusCode == 404 {
        errorDescription = "No resource exists for url \(response!.url)"
        code = ErrorCode.notFound
      } else if statusCode >= 500 {
        errorDescription = "Server encountered an error. \(response!.url)"
        code = ErrorCode.serverError
      }
      
      let userInfo = [NSLocalizedDescriptionKey: errorDescription]
      completionHandler(nil, NSError(domain: CGEClient.errorDomain, code: code.rawValue, userInfo: userInfo))
      
      return
    }
    
    guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
      let userInfo = [NSLocalizedDescriptionKey: "Error while parsing json"]
      completionHandler(nil, NSError(domain: CGEClient.errorDomain, code: ErrorCode.invalidJSON.rawValue,
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
