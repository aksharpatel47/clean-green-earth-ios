//
//  CGEClient+Attendance.swift
//  CleanGreenEarth
//
//  Created by Techniexe on 25/11/16.
//  Copyright © 2016 Akshar Patel. All rights reserved.
//

import Foundation

extension CGEClient {
  func attendEvent(withId eventId: String, completionHandler: @escaping (Any?, Error?) -> Void) {
    request(method: .POST, path: Paths.eventSpecificAttendance.replacingOccurrences(of: "{id}", with: eventId), queryString: nil, jsonBody: nil, completionHandler: completionHandler)
  }
  
  func removeAttendanceFromEvent(withId eventId: String, completionHandler: @escaping (Any?, Error?) -> Void) {
    request(method: .DELETE, path: Paths.eventSpecificAttendance.replacingOccurrences(of: "{id}", with: eventId), queryString: nil, jsonBody: nil, completionHandler: completionHandler)
  }
}
