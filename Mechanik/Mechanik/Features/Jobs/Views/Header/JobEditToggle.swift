//
//  JobEditToggle.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobEditToggle: View {
    @ObservedObject var vm: JobDetailViewModel

    var body: some View {
        if vm.isCompleted == false {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    vm.toggleEditMode()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: vm.isEditMode ? "xmark" : "pencil")
                    Text(vm.isEditMode ? "Düzenlemeyi Kapat" : "Düzenle / Güncelle")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(vm.isEditMode ? Color.primary : Color(.secondarySystemFill))
                .foregroundStyle(vm.isEditMode ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
}
