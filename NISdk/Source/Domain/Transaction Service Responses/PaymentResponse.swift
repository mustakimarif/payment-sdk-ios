//
//  PaymentResponse.swift
//  NISdk
//
//  Created by Johnny Peter on 20/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation

@objc public class PaymentResponse: NSObject, Codable {
    let _id: String
    let state: String
    let amount: Amount?
    let embeddedData: EmbeddedData?
    let paymentLinks: PaymentLinks?
    
    private enum PaymentResponseCodingKeys: String, CodingKey {
        case _id
        case state
        case amount
        case embeddedData = "_embedded"
        case paymentLinks = "_links"
    }
    
    required public init(from decoder: Decoder) throws {
        let paymentResponseContainer = try decoder.container(keyedBy: PaymentResponseCodingKeys.self)
        _id = try paymentResponseContainer.decode(String.self, forKey: ._id)
        state = try paymentResponseContainer.decode(String.self, forKey: .state)
        amount = try paymentResponseContainer.decode(Amount.self, forKey: .amount)
        embeddedData = try paymentResponseContainer.decodeIfPresent(EmbeddedData.self, forKey: .embeddedData)
        paymentLinks = try paymentResponseContainer.decodeIfPresent(PaymentLinks.self, forKey: .paymentLinks)
    }
}
