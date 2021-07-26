//
//  ValueListRoutes.swift
//  Stripe
//
//  Created by Andrew Edwards on 3/30/19.
//

import NIO
import NIOHTTP1
import Baggage

public protocol ValueListRoutes {
    /// Creates a new `ValueList` object, which can then be referenced in rules.
    ///
    /// - Parameters:
    ///   - alias: The name of the value list for use in rules.
    ///   - name: The human-readable name of the value list.
    ///   - itemType: Type of the items in the value list. One of `card_fingerprint`, `card_bin`, `email`, `ip_address`, `country`, `string`, or`case_sensitive_string`. Use string if the item type is unknown or mixed.
    ///   - metadata: Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Individual keys can be unset by posting an empty value to them. All keys can be unset by posting an empty value to `metadata`.
    /// - Returns: A`StripeValueList`.
    func create(alias: String, name: String, itemType: StripeValueListItemType?, metadata: [String: String]?, context: LoggingContext) -> EventLoopFuture<StripeValueList>
    
    /// Retrieves a `ValueList` object.
    ///
    /// - Parameter valueList: The identifier of the value list to be retrieved.
    /// - Returns: A`StripeValueList`.
    func retrieve(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeValueList>
    
    /// Updates a `ValueList` object by setting the values of the parameters passed. Any parameters not provided will be left unchanged. Note that `item_type` is immutable.
    ///
    /// - Parameters:
    ///   - valueList: The identifier of the value list to be updated.
    ///   - alias: The name of the value list for use in rules.
    ///   - metadata: Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Individual keys can be unset by posting an empty value to them. All keys can be unset by posting an empty value to `metadata`.
    ///   - name: The human-readable name of the value list.
    /// - Returns: A`StripeValueList`.
    func update(valueList: String, alias: String?, metadata: [String: String]?, name: String?, context: LoggingContext) -> EventLoopFuture<StripeValueList>
    
    /// Deletes a `ValueList` object, also deleting any items contained within the value list. To be deleted, a value list must not be referenced in any rules.
    ///
    /// - Parameter valueList: The identifier of the value list to be deleted.
    /// - Returns: A `StripeDeletedObject`.
    func delete(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject>
    
    /// Returns a list of `ValueList` objects. The objects are sorted in descending order by creation date, with the most recently created object appearing first.
    ///
    /// - Parameter filter: A dictionary that will be used for the query parameters. [See More →](https://stripe.com/docs/api/radar/value_lists/list).
    /// - Returns: A `StripeValueListList`
    func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripeValueListList>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension ValueListRoutes {
    func create(alias: String,
                name: String,
                itemType: StripeValueListItemType? = nil,
                metadata: [String: String]? = nil,
                context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        return create(alias: alias,
                      name: name,
                      itemType: itemType,
                      metadata: metadata,
                      context: context)
    }
    
    func retrieve(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        return retrieve(valueList: valueList, context: context)
    }
    
    func update(valueList: String,
                alias: String? = nil,
                metadata: [String: String]? = nil,
                name: String? = nil,
                context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        return update(valueList: valueList,
                      alias: alias,
                      metadata: metadata,
                      name: name,
                      context: context)
    }
    
    func delete(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject> {
        return delete(valueList: valueList, context: context)
    }
    
    func listAll(filter: [String: Any]? = nil, context: LoggingContext) -> EventLoopFuture<StripeValueListList> {
        return listAll(filter: filter, context: context)
    }
}

public struct StripeValueListRoutes: ValueListRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: StripeAPIHandler
    private let valuelists = APIBase + APIVersion + "radar/value_lists"
    
    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }
    
    public func create(alias: String,
                       name: String,
                       itemType: StripeValueListItemType?,
                       metadata: [String: String]?,
                       context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        var body: [String: Any] = ["alias": alias,
                                   "name": name]
        
        if let itemType = itemType {
            body["item_type"] = itemType.rawValue
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        return apiHandler.send(method: .POST, path: valuelists, body: .string(body.queryParameters), headers: headers, context: context)
    }
    
    public func retrieve(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        return apiHandler.send(method: .GET, path: "\(valuelists)/\(valueList)", headers: headers, context: context)
    }
    
    public func update(valueList: String,
                       alias: String?,
                       metadata: [String: String]?,
                       name: String?,
                       context: LoggingContext) -> EventLoopFuture<StripeValueList> {
        var body: [String: Any] = [:]
        
        if let alias = alias {
            body["alias"] = alias
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let name = name {
            body["name"] = name
        }
        
        return apiHandler.send(method: .POST, path: "\(valuelists)/\(valueList)", body: .string(body.queryParameters), headers: headers, context: context)
    }
    
    public func delete(valueList: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject> {
        return apiHandler.send(method: .DELETE, path: "\(valuelists)/\(valueList)", headers: headers, context: context)
    }
    
    public func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripeValueListList> {
        var queryParams = ""
        if let filter = filter {
            queryParams = filter.queryParameters
        }
        return apiHandler.send(method: .GET, path: valuelists, query: queryParams, headers: headers, context: context)
    }
}
