//
//  NITransaction.swift
//  NISdk
//
//  Created by Johnny Peter on 08/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation

/* protocol conforming to transaction service */
@objc protocol TransactionService {
    @objc func authorizePayment(for authCode: String,
                                using authorizationLink: String,
                                on completion: @escaping (String?) -> Void)
    
    @objc func getOrder(with orderId: String,
                        under outlet: String,
                        using paymentToken: String)
    
    @objc func makePayment(for order: OrderResponse,
                           with paymentInfo: PaymentRequest,
                           using paymentToken: String,
                           on completion: @escaping (HttpResponseCallback))
}
