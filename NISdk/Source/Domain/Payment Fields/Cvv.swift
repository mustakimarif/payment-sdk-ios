//
//  cvv.swift
//  NISdk
//
//  Created by Johnny Peter on 21/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation

class Cvv {
    var value: String? {
        didSet {
            if let value = self.value {
                let isValid = self.validateCvv()
                NotificationCenter.default.post(name: .didChangeCVV,
                                                object: self,
                                                userInfo: ["value": value, "isValid": isValid])
            }
        }
    }
    
    func validateCvv() -> Bool {
        return true
    }
}

