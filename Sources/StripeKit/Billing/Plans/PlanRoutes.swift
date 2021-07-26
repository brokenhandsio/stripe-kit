//
//  PlanRoutes.swift
//  Stripe
//
//  Created by Andrew Edwards on 5/29/17.
//
//

import NIO
import NIOHTTP1
import Baggage

public protocol PlanRoutes {
    /// You can create plans using the API, or in the Stripe Dashboard.
    ///
    /// - Parameters:
    ///   - id: An identifier randomly generated by Stripe. Used to identify this plan when subscribing a customer. You can optionally override this ID, but the ID must be unique across all plans in your Stripe account. You can, however, use the same plan ID in both live and test modes.
    ///   - currency: Three-letter ISO currency code, in lowercase. Must be a supported currency.
    ///   - interval: Specifies billing frequency. Either day, week, month or year.
    ///   - product: The product whose pricing the created plan will represent. This can either be the ID of an existing product, or a dictionary containing fields used to create a service product.
    ///   - active: Whether the plan is currently available for new subscriptions. Defaults to `true`.
    ///   - aggregateUsage: Specifies a usage aggregation strategy for plans of `usage_type=metered`. Allowed values are `sum` for summing up all usage during a period, `last_during_period` for picking the last usage record reported within a period, `last_ever` for picking the last usage record ever (across period bounds) or `max` which picks the usage record with the maximum reported usage during a period. Defaults to `sum`.
    ///   - amount: A positive integer in cents (or 0 for a free plan) representing how much to charge on a recurring basis.
    ///   - amountDecimal: Same as amount, but accepts a decimal value with at most 12 decimal places. Only one of amount and amount_decimal can be set.
    ///   - billingScheme: Describes how to compute the price per period. Either `per_unit` or `tiered`. `per_unit` indicates that the fixed amount (specified in `amount`) will be charged per unit in `quantity` (for plans with `usage_type=licensed`), or per unit of total usage (for plans with `usage_type=metered`). `tiered` indicates that the unit pricing will be computed using a tiering strategy as defined using the `tiers` and `tiers_mode` attributes.
    ///   - intervalCount: The number of intervals between subscription billings. For example, `interval=month` and `interval_count=3` bills every 3 months. Maximum of one year interval allowed (1 year, 12 months, or 52 weeks).
    ///   - metadata: A set of key-value pairs that you can attach to a plan object. It can be useful for storing additional information about the plan in a structured format.
    ///   - nickname: A brief description of the plan, hidden from customers.
    ///   - tiers: Each element represents a pricing tier. This parameter requires `billing_scheme` to be set to `tiered`. See also the documentation for `billing_scheme`.
    ///   - tiersMode: Defines if the tiering price should be `graduated` or `volume` based. In `volume`-based tiering, the maximum quantity within a period determines the per unit price, in `graduated` tiering pricing can successively change as the quantity grows.
    ///   - transformUsage: Apply a transformation to the reported usage or set quantity before computing the billed price. Cannot be combined with `tiers`.
    ///   - trialPeriodDays: Default number of trial days when subscribing a customer to this plan using `trial_from_plan=true`.
    ///   - usageType: Configures how the quantity per period should be determined, can be either `metered` or `licensed`. `licensed` will automatically bill the `quantity` set for a plan when adding it to a subscription, `metered` will aggregate the total usage based on usage records. Defaults to `licensed`.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripePlan`.
    func create(id: String?,
                currency: StripeCurrency,
                interval: StripePlanInterval,
                product: Any,
                active: Bool?,
                aggregateUsage: StripePlanAggregateUsage?,
                amount: Int?,
                amountDecimal: Int?,
                billingScheme: StripePlanBillingScheme?,
                intervalCount: Int?,
                metadata: [String: String]?,
                nickname: String?,
                tiers: [String: Any]?,
                tiersMode: StripePlanTiersMode?,
                transformUsage: [String: Any]?,
                trialPeriodDays: Int?,
                usageType: StripePlanUsageType?,
                expand: [String]?,
                context: LoggingContext) -> EventLoopFuture<StripePlan>
    
    /// Retrieves the plan with the given ID.
    ///
    /// - Parameters:
    ///   - plan: The ID of the desired plan.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripePlan`.
    func retrieve(plan: String, expand: [String]?, context: LoggingContext) -> EventLoopFuture<StripePlan>
    
    /// Updates the specified plan by setting the values of the parameters passed. Any parameters not provided are left unchanged. By design, you cannot change a plan’s ID, amount, currency, or billing cycle.
    ///
    /// - Parameters:
    ///   - plan: The identifier of the plan to be updated.
    ///   - active: Whether the plan is currently available for new subscriptions.
    ///   - metadata: A set of key-value pairs that you can attach to a plan object. It can be useful for storing additional information about the plan in a structured format.
    ///   - nickname: A brief description of the plan, hidden from customers. This will be unset if you POST an empty value.
    ///   - product: The product the plan belongs to. Note that after updating, statement descriptors and line items of the plan in active subscriptions will be affected.
    ///   - trialPeriodDays: Default number of trial days when subscribing a customer to this plan using `trial_from_plan=true`.
    ///   - expand: An array of properties to expand.
    /// - Returns: A `StripePlan`.
    func update(plan: String,
                active: Bool?,
                metadata: [String: String]?,
                nickname: String?,
                product: Any?,
                trialPeriodDays: Int?,
                expand: [String]?,
                context: LoggingContext) -> EventLoopFuture<StripePlan>
    
    /// Deleting plans means new subscribers can’t be added. Existing subscribers aren’t affected.
    ///
    /// - Parameter plan: The identifier of the plan to be deleted.
    /// - Returns: A `StripeDeletedObject`
    func delete(plan: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject>
    
    /// Returns a list of your plans.
    ///
    /// - Parameter filter: A dictionary that will be used for the query parameters. [See More →](https://stripe.com/docs/api/plans/list)
    /// - Returns: A `StripePlanList`
    func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripePlanList>
    
    /// Headers to send with the request.
    var headers: HTTPHeaders { get set }
}

extension PlanRoutes {
    public func create(id: String? = nil,
                       currency: StripeCurrency,
                       interval: StripePlanInterval,
                       product: Any,
                       active: Bool? = nil,
                       aggregateUsage: StripePlanAggregateUsage? = nil,
                       amount: Int? = nil,
                       amountDecimal: Int? = nil,
                       billingScheme: StripePlanBillingScheme? = nil,
                       intervalCount: Int? = nil,
                       metadata: [String: String]? = nil,
                       nickname: String? = nil,
                       tiers: [String: Any]? = nil,
                       tiersMode: StripePlanTiersMode? = nil,
                       transformUsage: [String: Any]? = nil,
                       trialPeriodDays: Int? = nil,
                       usageType: StripePlanUsageType? = nil,
                       expand: [String]? = nil,
                       context: LoggingContext) -> EventLoopFuture<StripePlan> {
        return create(id: id,
                      currency: currency,
                      interval: interval,
                      product: product,
                      active: active,
                      aggregateUsage: aggregateUsage,
                      amount: amount,
                      amountDecimal: amountDecimal,
                      billingScheme: billingScheme,
                      intervalCount: intervalCount,
                      metadata: metadata,
                      nickname: nickname,
                      tiers: tiers,
                      tiersMode: tiersMode,
                      transformUsage: transformUsage,
                      trialPeriodDays: trialPeriodDays,
                      usageType: usageType,
                      expand: expand)
    }
    
    public func retrieve(plan: String, expand: [String]? = nil, context: LoggingContext) -> EventLoopFuture<StripePlan> {
        return retrieve(plan: plan, expand: expand)
    }
    
    public func update(plan: String,
                       active: Bool? = nil,
                       metadata: [String: String]? = nil,
                       nickname: String? = nil,
                       product: Any? = nil,
                       trialPeriodDays: Int? = nil,
                       expand: [String]? = nil,
                       context: LoggingContext) -> EventLoopFuture<StripePlan> {
        return update(plan: plan,
                      active: active,
                      metadata: metadata,
                      nickname: nickname,
                      product: product,
                      trialPeriodDays: trialPeriodDays,
                      expand: expand)
    }
    
    public func delete(plan: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject> {
        return delete(plan: plan)
    }
    
    public func listAll(filter: [String: Any]? = nil, context: LoggingContext) -> EventLoopFuture<StripePlanList> {
        return listAll(filter: filter)
    }
}

public struct StripePlanRoutes: PlanRoutes {
    public var headers: HTTPHeaders = [:]
    
    private let apiHandler: StripeAPIHandler
    private let plans = APIBase + APIVersion + "plans"
    
    init(apiHandler: StripeAPIHandler) {
        self.apiHandler = apiHandler
    }
    
    public func create(id: String?,
                       currency: StripeCurrency,
                       interval: StripePlanInterval,
                       product: Any,
                       active: Bool?,
                       aggregateUsage: StripePlanAggregateUsage?,
                       amount: Int?,
                       amountDecimal: Int?,
                       billingScheme: StripePlanBillingScheme?,
                       intervalCount: Int?,
                       metadata: [String: String]?,
                       nickname: String?,
                       tiers: [String: Any]?,
                       tiersMode: StripePlanTiersMode?,
                       transformUsage: [String: Any]?,
                       trialPeriodDays: Int?,
                       usageType: StripePlanUsageType?,
                       expand: [String]?,
                       context: LoggingContext) -> EventLoopFuture<StripePlan> {
        var body: [String: Any] = ["currency": currency.rawValue,
                                   "interval": interval.rawValue]
        
        
        if let product = product as? String {
            body["product"] = product
        } else if let product = product as? [String: Any]  {
            product.forEach { body["product[\($0)]"] = $1 }
        }
        
        if let id = id {
            body["id"] = id
        }
        
        if let active = active {
            body["active"] = active
        }
        
        if let aggregateUsage = aggregateUsage {
            body["aggregate_usage"] = aggregateUsage.rawValue
        }
        
        if let amount = amount {
            body["amount"] = amount
        }
        
        if let amountDecimal = amountDecimal {
            body["amount_decimal"] = amountDecimal
        }
        
        if let billingScheme = billingScheme {
            body["billing_scheme"] = billingScheme.rawValue
        }
        
        if let intervalCount = intervalCount {
            body["interval_count"] = intervalCount
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let nickname = nickname {
            body["nickname"] = nickname
        }
        
        if let tiers = tiers {
            tiers.forEach { body["tiers[\($0)]"] = $1 }
        }
        
        if let tiersMode = tiersMode {
            body["tiers_mode"] = tiersMode.rawValue
        }
        
        if let transformUsage = transformUsage {
            transformUsage.forEach { body["transform_usage[\($0)]"] = $1 }
        }
        
        if let trialperiodDays = trialPeriodDays {
            body["trial_period_days"] = trialperiodDays
        }
        
        if let expand = expand {
            body["expand"] = expand
        }
        
        return apiHandler.send(method: .POST, path: plans, body: .string(body.queryParameters), headers: headers)
    }

    public func retrieve(plan: String, expand: [String]?, context: LoggingContext) -> EventLoopFuture<StripePlan> {
        var queryParams = ""
        if let expand = expand {
            queryParams = ["expand": expand].queryParameters
        }
        
        return apiHandler.send(method: .GET, path: "\(plans)/\(plan)", query: queryParams, headers: headers)
    }
    
    public func update(plan: String,
                       active: Bool?,
                       metadata: [String: String]?,
                       nickname: String?,
                       product: Any?,
                       trialPeriodDays: Int?,
                       expand: [String]?,
                       context: LoggingContext) -> EventLoopFuture<StripePlan> {
        var body: [String: Any] = [:]
        
        if let active = active {
            body["active"] = active
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }

        if let nickname = nickname {
            body["nickname"] = nickname
        }
        
        if let product = product as? String {
            body["product"] = product
        } else if let product = product as? [String: Any]  {
            product.forEach { body["product[\($0)]"] = $1 }
        }
        
        if let trialPeriodDays = trialPeriodDays {
            body["trial_period_days"] = trialPeriodDays
        }
        
        if let expand = expand {
            body["expand"] = expand
        }
        
        return apiHandler.send(method: .POST, path: "\(plans)/\(plan)", body: .string(body.queryParameters), headers: headers)
    }
    
    public func delete(plan: String, context: LoggingContext) -> EventLoopFuture<StripeDeletedObject> {
        return apiHandler.send(method: .DELETE, path: "\(plans)/\(plan)", headers: headers)
    }
    
    public func listAll(filter: [String: Any]?, context: LoggingContext) -> EventLoopFuture<StripePlanList> {
        var queryParams = ""
        if let filter = filter {
            queryParams = filter.queryParameters
        }
        
        return apiHandler.send(method: .GET, path: plans, query: queryParams, headers: headers)
    }
}
