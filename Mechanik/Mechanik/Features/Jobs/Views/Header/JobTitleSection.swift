//
//  JobTitleSection.swift
//  Mechanik
//
//  Created by efe arslan on 30.04.2026.
//

import SwiftUI

struct JobTitleSection: View {
    let job: JobListItem

    init(vm: JobDetailViewModel) {
        self.job = vm.job
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(job.title)
                .font(.title3.weight(.bold))

            Text("ID: \(job.id)")
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
    }
}
