//
//  CurrencyFormatting.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import Foundation

extension Double {
    var formattedCurrency: String {
        formatted(.currency(code: "TRY").precision(.fractionLength(0)))
    }
}
