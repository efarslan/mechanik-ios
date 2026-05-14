//
//  label.swift
//  Mechanik
//
//  Created by efe arslan on 14.05.2026.
//

import SwiftUI

struct LabeledRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(.footnote, design: .monospaced).weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    LabeledRow(label: "Label", value: "Value")
}
