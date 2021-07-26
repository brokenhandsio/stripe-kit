//
//  PortalConfigurationRoutes.swift
//  
//
//  Created by Andrew Edwards on 2/25/21.
//

import NIO
import NIOHTTP1
import Baggage

public protocol PortalConfigurationRoutes {
    /// Creates a configuration that describes the functionality and behavior of a PortalSession
    /// - Parameters:
    ///   - businessProfile: The business information shown to customers in the portal.
    ///   - features: Information about the features available in the portal.
    ///   - defaultReturnUrl: The default URL to redirect customers to when they click on the portal’s link to return to your website. This can be overriden when creating the session.
    func create(businessProfile: [String: Any],
                features: [String: Any],
                defaultReturnUrl: String?,
                context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration>
    
    /// Updates a configuration that describes the functionality of the customer portal.
    /// - Parameters:
    ///   - configuration: The identifier of the configuration to update.
    ///   - active: Whether the configuration is active and can be used to create portal sessions.
    ///   - businessProfile: The business information shown to customers in the portal.
    ///   - defaultReturnUrl: The default URL to redirect customers to when they click on the portal’s link to return to your website. This can be overriden when creating the session.
    ///   - features: Information about the features available in the portal.
    func update(configuration: String,
                active: Bool?,
                businessProfile: [String: Any]?,
                defaultReturnUrl: String?,
                features: [String: Any]?,
                context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration>
    
    /// Retrieves a configuration that describes the functionality of the customer portal.
    /// - Parameter configuration: The identifier of the configuration to retrieve.
    func retrieve(configuration: String, context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration>
    
    /// Returns a list of tax IDs for a customer.
    ///
    /// - Parameter filter: A dictionary that will be used for the query parameters.
    /// - Returns: A `StripePortalConfigurationList`.
    func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripePortalConfigurationList>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension PortalConfigurationRoutes {
    public func create(businessProfile: [String: Any],
                       features: [String: Any],
                       defaultReturnUrl: String? = nil,
                       context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        create(businessProfile: businessProfile,
               features: features,
               defaultReturnUrl: defaultReturnUrl,
               context: context)
    }
    
    public func update(configuration: String,
                       active: Bool? = nil,
                       businessProfile: [String: Any]? = nil,
                       defaultReturnUrl: String? = nil,
                       features: [String: Any]? = nil,
                       context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        update(configuration: configuration,
               active: active,
               businessProfile: businessProfile,
               defaultReturnUrl: defaultReturnUrl,
               features: features,
               context: context)
    }
    
    public func retrieve(configuration: String, context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        retrieve(configuration: configuration, context: context)
    }
    
    public func listAll(filter: [String: Any]? = nil, context: LoggingContext) -> EventLoopFuture<StripePortalConfigurationList> {
        listAll(filter: filter, context: context)
    }
}

public struct StripePortalConfigurationRoutes: PortalConfigurationRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: StripeAPIHandler
    private let portalconfiguration = APIBase + APIVersion + "billing_portal/configurations"
    
    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }
    
    public func create(businessProfile: [String: Any],
                       features: [String: Any],
                       defaultReturnUrl: String?,
                       context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        var body: [String: Any] = [:]
        
        businessProfile.forEach { body["business_profile[\($0)]"] = $1 }
        
        features.forEach { body["features[\($0)]"] = $1 }
        
        if let defaultReturnUrl = defaultReturnUrl {
            body["default_return_url"] = defaultReturnUrl
        }
        
        return apiHandler.send(method: .POST, path: portalconfiguration, body: .string(body.queryParameters), headers: headers, context: context)
    }
    
    public func update(configuration: String,
                       active: Bool?,
                       businessProfile: [String: Any]?,
                       defaultReturnUrl: String?,
                       features: [String: Any]?,
                       context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        var body: [String: Any] = [:]
        
        if let active = active {
            body["active"] = active
        }
        
        if let businessProfile = businessProfile {
            businessProfile.forEach { body["business_profile[\($0)]"] = $1 }
        }
        
        if let features = features {
            features.forEach { body["features[\($0)]"] = $1 }
        }
        
        if let defaultReturnUrl = defaultReturnUrl {
            body["default_return_url"] = defaultReturnUrl
        }
        
        return apiHandler.send(method: .POST, path: "\(portalconfiguration)/\(configuration)", body: .string(body.queryParameters), headers: headers, context: context)
    }
    
    public func retrieve(configuration: String, context: LoggingContext) -> EventLoopFuture<StripePortalConfiguration> {
        return apiHandler.send(method: .GET, path: "\(portalconfiguration)/\(configuration)", headers: headers, context: context)
    }
    
    public func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripePortalConfigurationList> {
        var queryParams = ""
        if let filter = filter {
            queryParams = filter.queryParameters
        }
        
        return apiHandler.send(method: .GET, path: portalconfiguration, query: queryParams, headers: headers, context: context)
    }
}
