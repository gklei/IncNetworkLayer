//
//  IncNetworkFormRequest.swift
//  IncNetworkLayer
//
//  Created by Gregory Klein on 7/6/17.
//

import Foundation

public protocol IncNetworkFormRequest: IncNetworkRequest {}

extension IncNetworkFormRequest {
   public var method: IncNetworkService.Method { return .post }
   public var headers: [String : String]? { return defaultFormHeaders() }
   
   public func decode(data: Data?, response: URLResponse?) throws -> Any? {
      guard let data = data, !data.isEmpty else { return nil }
      let form = try JSONSerialization.jsonObject(with: data, options: [])
      return form
   }
   
   public func body(parameters: [String : Any]?, encoding: String.Encoding = .utf8, isURLEncoded: Bool = true) throws -> Data? {
      
      var optionalBody: String?
      if isURLEncoded {
         do {
            optionalBody = try self.query(with: parameters)
         } catch {
            switch error {
            case IncNetworkRequestError.invalidQueryParameter(let name): throw IncNetworkRequestError.invalidBodyParameter(name: name)
            default: throw error
            }
         }
      } else {
         optionalBody = parameters?.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
      }
      
      guard let body = optionalBody else { return nil }
      guard let data = body.data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
      
      return data
   }
   
   public func defaultFormHeaders(isURLEncoded: Bool = true) -> [String: String] {
      return ["Content-Type": isURLEncoded ? "application/x-www-form-urlencoded" : "multipart/form-data"]
   }
}

public protocol IncNetworkJSONFormRequest: IncNetworkJSONRequest, IncNetworkFormRequest {}
public extension IncNetworkJSONFormRequest {
   var method: IncNetworkService.Method { return .post }
   
   func decode(data: Data?, response: URLResponse?) throws -> Any? {
      guard let data = data, !data.isEmpty else { return nil }
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      return json
   }
}