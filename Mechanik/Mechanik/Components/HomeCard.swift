//
//  HomeCard.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//


import SwiftUI

struct HomeCard: View {
    
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        HStack {
            
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}