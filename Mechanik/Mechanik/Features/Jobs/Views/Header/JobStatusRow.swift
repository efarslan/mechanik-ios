//
//  JobStatusRow.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobStatusRow: View {
    @ObservedObject var vm: JobDetailViewModel

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(vm.statusColor)
                .frame(width: 8, height: 8)

            Text(vm.statusTitle)
                .font(.caption.weight(.bold))
                .foregroundStyle(vm.statusColor)

            Spacer()

            if let createdAt = vm.job.createdAt {
                Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
