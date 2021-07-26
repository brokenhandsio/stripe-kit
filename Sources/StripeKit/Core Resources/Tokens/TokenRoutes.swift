//
//  TokenRoutes.swift
//  Stripe
//
//  Created by Anthony Castelli on 5/12/17.
//
//

import NIO
import NIOHTTP1
import Baggage

public protocol TokenRoutes {
    /// Creates a single-use token that represents a credit card’s details. This token can be used in place of a credit card dictionary with any API method. These tokens can be used only once: by creating a new Charge object, or by attaching them to a Customer object. /n In most cases, you should use our recommended payments integrations instead of using the API.
    ///
    /// - Parameters:
    ///   - card: The card this token will represent. If you also pass in a customer, the card must be the ID of a card belonging to the customer. Otherwise, if you do not pass in a customer, this is a dictionary containing a user's credit card details, with the options described below.
    ///   - customer: The customer (owned by the application's account) for which to create a token. For use only with Stripe Connect. Also, this can be used only with an OAuth access token or Stripe-Account header. For more details, see Shared Customers.
    /// - Returns: A `StripeToken`.
    func create(card: Any?, customer: String?, context: LoggingContext) -> EventLoopFuture<StripeToken>
    
    /// Creates a single-use token that represents a bank account’s details. This token can be used with any API method in place of a bank account dictionary. This token can be used only once, by attaching it to a Custom account.
    ///
    /// - Parameters:
    ///   - bankAcocunt: The bank account this token will represent.
    ///   - customer: The customer (owned by the application’s account) for which to create a token. For use only with Stripe Connect. Also, this can be used only with an OAuth access token or Stripe-Account header. For more details, see Shared Customers.
    /// - Returns: A `StripeToken`.
    func create(bankAcocunt: [String: Any]?, customer: String?, context: LoggingContext) -> EventLoopFuture<StripeToken>
    
    /// Creates a single-use token that represents the details of personally identifiable information (PII). This token can be used in place of an id_number in Account or Person Update API methods. A PII token can be used only once.
    ///
    /// - Parameter pii: The PII this token will represent.
    /// - Returns: A `StripeToken`.
    func create(pii: String, context: LoggingContext) -> EventLoopFuture<StripeToken>
    
    /// Creates a single-use token that wraps a user’s legal entity information. Use this when creating or updating a Connect account. See the account tokens documentation to learn more. /n Account tokens may be created only in live mode, with your application’s publishable key. Your application’s secret key may be used to create account tokens only in test mode.
    ///
    /// - Parameter account: Information for the account this token will represent.
    /// - Returns: A `StripeToken`.
    func create(account: [String: Any], context: LoggingContext) -> EventLoopFuture<StripeToken>
    
    /// Creates a single-use token that represents the details for a person. Use this when creating or updating persons associated with a Connect account. See the documentation to learn more. Person tokens may be created only in live mode, with your application’s publishable key. Your application’s secret key may be used to create person tokens only in test mode.
    /// - Parameter person: Information for the person this token will represent.
    func create(person: [String: Any], context: LoggingContext) -> EventLoopFuture<StripePerson>
    
    /// Retrieves the token with the given ID.
    ///
    /// - Parameter token: The ID of the desired token.
    /// - Returns: A `StripeToken`.
    func retrieve(token: String, context: LoggingContext) -> EventLoopFuture<StripeToken>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension TokenRoutes {
    public func create(card: Any? = nil, customer: String? = nil, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return create(card: card, customer: customer)
    }
    
    public func create(bankAcocunt: [String: Any]? = nil, customer: String? = nil, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return create(bankAcocunt: bankAcocunt, customer: customer)
    }
    
    public func create(pii: String, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return create(pii: pii)
    }
    
    public func create(account: [String: Any], context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return create(account: account)
    }
    
    public func create(person: [String: Any], context: LoggingContext) -> EventLoopFuture<StripePerson> {
        return create(person: person)
    }
    
    public func retrieve(token: String, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return retrieve(token: token)
    }
}

public struct StripeTokenRoutes: TokenRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: StripeAPIHandler
    private let tokens = APIBase + APIVersion + "tokens"
    
    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }

    public func create(card: Any?, customer: String?, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        var body: [String: Any] = [:]
        
        if let card = card as? [String: Any] {
            card.forEach { body["card[\($0)]"] = $1 }
        }
        
        if let card = card as? String {
            body["card"] = card
        }
        
        if let customer = customer {
            body["customer"] = customer
        }
        
        return apiHandler.send(method: .POST, path: tokens, body: .string(body.queryParameters), headers: headers)
    }
    
    public func create(bankAcocunt: [String: Any]?, customer: String?, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        var body: [String: Any] = [:]
        
        if let bankAcocunt = bankAcocunt {
            bankAcocunt.forEach { body["bank_account[\($0)]"] = $1 }
        }
        
        if let customer = customer {
            body["customer"] = customer
        }
        
        return apiHandler.send(method: .POST, path: tokens, body: .string(body.queryParameters), headers: headers)
    }
    
    public func create(pii: String, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        let body: [String: Any] = ["personal_id_number": pii]
        
        return apiHandler.send(method: .POST, path: tokens, body: .string(body.queryParameters), headers: headers)
    }
    
    public func create(account: [String: Any], context: LoggingContext) -> EventLoopFuture<StripeToken> {
        var body: [String: Any] = [:]
        
        account.forEach { body["account[\($0)]"] = $1 }
        
        return apiHandler.send(method: .POST, path: tokens, body: .string(body.queryParameters), headers: headers)
    }
    
    public func create(person: [String : Any], context: LoggingContext) -> EventLoopFuture<StripePerson> {
        var body: [String: Any] = [:]
        
        person.forEach { body["person[\($0)]"] = $1 }
        
        return apiHandler.send(method: .POST, path: tokens, body: .string(body.queryParameters), headers: headers)
    }
    
    public func retrieve(token: String, context: LoggingContext) -> EventLoopFuture<StripeToken> {
        return apiHandler.send(method: .GET, path: "\(tokens)/\(token)", headers: headers)
    }
}
