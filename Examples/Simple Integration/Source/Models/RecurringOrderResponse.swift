//
//  RecurringOrderResponse.swift
//  Simple Integration
//
//  Created by Mustakim Patvekar on 20/06/23.
//  Copyright © 2023 Network International. All rights reserved.
//

import NISdk

import Foundation

@objc public class RecurringOrderResponse: NSObject, Codable {
    public var amount: Amount?
    public var reference: String?
    public var orderLinks: OrderLinks?
    public var embeddedData: EmbeddedData?
    
    public enum OrderCodingKeys: String, CodingKey {
        case amount
        case reference
        case orderLinks = "_links"
        case embeddedData = "_embedded"
    }
    
    public func getAuthCode() -> String? {
        if let payPageLink = orderLinks?.payPageLink,
            let url = URLComponents(string: payPageLink) {
            return url.queryItems?.first(where: { $0.name == "code" })?.value
        }
        return nil
    }
    
    @objc public static func decodeFrom(data: Data) throws -> RecurringOrderResponse {
        do {
            let orderResponse = try JSONDecoder().decode(RecurringOrderResponse.self, from: data)
            return orderResponse
        } catch let error {
            throw error
        }
    }
    
    override required init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let OrderResponseContainer = try decoder.container(keyedBy: OrderCodingKeys.self)
        amount = try OrderResponseContainer.decodeIfPresent(Amount.self, forKey: .amount)
        reference = try OrderResponseContainer.decodeIfPresent(String.self, forKey: .reference)
        orderLinks = try OrderResponseContainer.decodeIfPresent(OrderLinks.self, forKey:.orderLinks)
        embeddedData = try OrderResponseContainer.decodeIfPresent(EmbeddedData.self, forKey: .embeddedData)
    }
    
    class Builder {
        private var orderResponse = RecurringOrderResponse()
    

        func build() -> RecurringOrderResponse {
            return orderResponse
        }
        
    }
}

