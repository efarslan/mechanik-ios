//
//  JobDetailHeaderView.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobDetailHeaderView: View {
    @ObservedObject var vm: JobDetailViewModel
    let onDismissRequested: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            JobStatusRow(vm: vm)
            JobTitleSection(vm: vm)
            JobEditToggle(vm: vm)
            JobStatusActions(vm: vm, onDismissRequested: onDismissRequested)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
