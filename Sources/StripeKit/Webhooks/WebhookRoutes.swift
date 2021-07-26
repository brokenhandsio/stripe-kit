//
//  WebhookRoutes.swift
//  
//
//  Created by Andrew Edwards on 12/27/19.
//

import NIO
import NIOHTTP1
import Baggage

public protocol WebhookEndpointRoutes {
    /// A webhook endpoint must have a `url` and a list of `enabled_events`. You may optionally specify the Boolean `connect` parameter. If set to true, then a Connect webhook endpoint that notifies the specified `url` about events from all connected accounts is created; otherwise an account webhook endpoint that notifies the specified `url` only about events from your account is created. You can also create webhook endpoints in the [webhooks settings](https://dashboard.stripe.com/account/webhooks) section of the Dashboard.
    /// - Parameter enabledEvents: The list of events to enable for this endpoint. You may specify `['*']` to enable all events, except those that require explicit selection.
    /// - Parameter url: The URL of the webhook endpoint.
    /// - Parameter metadata: Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Individual keys can be unset by posting an empty value to them. All keys can be unset by posting an empty value to metadata.
    /// - Parameter apiVersion: Events sent to this endpoint will be generated with this Stripe Version instead of your account’s default Stripe Version.
    /// - Parameter connect: Whether this endpoint should receive events from connected accounts (true), or from your account (false). Defaults to false.
    func create(enabledEvents: [String],
                url: String,
                metadata: [String: String]?,
                apiVersion: String?,
                connect: Bool?,
                context: LoggingContext) -> EventLoopFuture<StripeWebhook>
    
    /// Retrieves the webhook endpoint with the given ID.
    /// - Parameter webhookEndpoint: The ID of the desired webhook endpoint.
    func retrieve(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook>
    
    /// Updates the webhook endpoint. You may edit the `url`, the list of `enabled_events`, and the status of your endpoint.
    /// - Parameter webhookEndpoint: The ID of the desired webhook endpoint.
    /// - Parameter disabled: Disable the webhook endpoint if set to true.
    /// - Parameter enabledEvents: The list of events to enable for this endpoint. You may specify `['*']` to enable all events, except those that require explicit selection.
    /// - Parameter url: The URL of the webhook endpoint.
    /// - Parameter metadata: Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Individual keys can be unset by posting an empty value to them. All keys can be unset by posting an empty value to metadata.
    func update(webhookEndpoint: String,
                disabled: Bool?,
                enabledEvents: [String]?,
                url: String?,
                metadata: [String: String]?,
                context: LoggingContext) -> EventLoopFuture<StripeWebhook>
    
    /// Returns a list of your webhook endpoints.
    /// - Parameter filter: A dictionary that will be used for the query parameters. [See More →](https://stripe.com/docs/api/sigma/webhooks/list)
    func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripeWebhookList>
    
    /// You can also delete webhook endpoints via the webhook endpoint management page of the Stripe dashboard.
    /// - Parameter webhookEndpoint: The ID of the webhook endpoint to delete.
    func delete(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension WebhookEndpointRoutes {
    func create(enabledEvents: [String],
                url: String,
                metadata: [String: String]? = nil,
                apiVersion: String? = nil,
                connect: Bool? = nil,
                context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return create(enabledEvents: enabledEvents, url: url, metadata: metadata, apiVersion: apiVersion, connect: connect)
    }
    
    func retrieve(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return retrieve(webhookEndpoint: webhookEndpoint)
    }
    
    func update(webhookEndpoint: String,
                disabled: Bool? = nil,
                enabledEvents: [String]? = nil,
                url: String? = nil,
                metadata: [String: String]? = nil,
                context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return update(webhookEndpoint: webhookEndpoint, disabled: disabled, enabledEvents: enabledEvents, url: url, metadata: metadata)
    }
    
    func listAll(filter: [String: Any]? = nil, context: LoggingContext) -> EventLoopFuture<StripeWebhookList> {
        return listAll(filter: filter)
    }
    
    func delete(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return delete(webhookEndpoint: webhookEndpoint)
    }
}

public struct StripeWebhookEndpointRoutes: WebhookEndpointRoutes {
    public var headers: HTTPHeaders = [:]

    private let apiHandler: StripeAPIHandler
    private let webhooks = APIBase + APIVersion + "webhook_endpoints"

    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }
    
    public func create(enabledEvents: [String], url: String, metadata: [String: String]?, apiVersion: String?, connect: Bool?, context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        var body: [String: Any] = ["enabled_events": enabledEvents,
                                   "url": url]
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let apiVersion = apiVersion {
            body["api_version"] = apiVersion
        }
        
        if let connect = connect {
            body["connect"] = connect
        }
        
        return apiHandler.send(method: .POST, path: webhooks, body: .string(body.queryParameters), headers: headers)
    }
    
    public func retrieve(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return apiHandler.send(method: .GET, path: "\(webhooks)/\(webhookEndpoint)", headers: headers)
    }
    
    public func update(webhookEndpoint: String,
                       disabled: Bool?,
                       enabledEvents: [String]?,
                       url: String?,
                       metadata: [String: String]?,
                       context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        var body: [String: Any] = [:]
        
        if let disabled = disabled {
            body["disabled"] = disabled
        }
        
        if let enabledEvents = enabledEvents {
            body["enabled_events"] = enabledEvents
        }
        
        if let url = url {
            body["url"] = url
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        return apiHandler.send(method: .POST, path: "\(webhooks)/\(webhookEndpoint)", body: .string(body.queryParameters), headers: headers)
    }
    
    public func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripeWebhookList> {
        var queryParams = ""
        if let filter = filter {
            queryParams = filter.queryParameters
        }
        return apiHandler.send(method: .GET, path: webhooks, query: queryParams, headers: headers)
    }
    
    public func delete(webhookEndpoint: String, context: LoggingContext) -> EventLoopFuture<StripeWebhook> {
        return apiHandler.send(method: .DELETE, path: "\(webhooks)/\(webhookEndpoint)", headers: headers)
    }
}

