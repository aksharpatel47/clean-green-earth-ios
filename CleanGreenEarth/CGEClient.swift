//
//  CGEClient.swift
//  CleanGreenEarth
//
//  Created by Akshar Patel on 21/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation
import Firebase

final class CGEClient {
  
  static let shared = CGEClient()
  
  static let errorDomain = "CGEErrorDomain"
  
  enum ErrorCode: Int {
    case unknown, authenticationFailed, generalError, malformedRequest, notFound, invalidJSON, serverError
  }
  
  enum HTTPMethods: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
  }
  
  func request(method: HTTPMethods, path: String, queryString: [String:Any]?, jsonBody: [String:Any]?,
                  completionHandler: @escaping ((Any?, Error?) -> Void)) {
    
    createRequest(method: method, path: path, queryString: queryString, jsonBody: jsonBody) {
      request, error in
      
      guard let request = request, error == nil else {
        completionHandler(nil, error)
        return
      }
      
      self.runDataTask(with: request, completionHandler: completionHandler)
    }
  }
  
  func uploadRequest(method: HTTPMethods, path: String, files: [CGEFile], data: [String:String]?, completionHandler: @escaping ((Any?, Error?) -> Void)) {
    createUploadRequest(method: method, path: path, files: files, mpData: data) {
      request, error in
      
      guard let request = request, error == nil else {
        completionHandler(nil, error)
        return
      }
      
      self.runDataTask(with: request, completionHandler: completionHandler)
    }
  }
  
  func downloadFile(withURLString urlString: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
      let error = NSError(domain: CGEClient.errorDomain, code: CGEClient.ErrorCode.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Error while creating URL."])
      completionHandler(nil, error)
      return
    }
    
    downloadFile(withURL: url, completionHandler: completionHandler)
  }
  
  func downloadFile(withURL url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
    let request = URLRequest(url: url)
    
    let task = URLSession.shared.dataTask(with: request) {
      data, response, error in
      
      completionHandler(data, error)
    }
    
    task.resume()
  }
}
