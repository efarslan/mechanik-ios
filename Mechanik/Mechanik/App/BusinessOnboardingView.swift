import SwiftUI

struct BusinessOnboardingView: View {

    enum Step {
        case choice
        case create
        case join
    }

    @Binding var businessName: String
    @Binding var inviteCode: String
    var businessNameError: String?
    var inviteCodeError: String?
    var generalError: String?
    let isCreating: Bool
    let isJoining: Bool
    let showsLogout: Bool
    let onCreate: () -> Void
    let onJoin: () -> Void
    let onLogout: () -> Void

    @State private var step: Step = .choice

    var body: some View {
        VStack(spacing: 12) {
            header

            switch step {
            case .choice:
                choiceStep
            case .create:
                createStep
            case .join:
                joinStep
            }

            if let generalError, !generalError.isEmpty {
                Text(generalError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            if showsLogout, step == .choice {
                Button("Çıkış Yap", role: .destructive) {
                    onLogout()
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: step == .join ? "person.badge.plus" : "sparkles")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.orange)

            Text(headerTitle)
                .font(.title3.weight(.bold))

            Text(headerSubtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var headerTitle: String {
        switch step {
        case .choice: return "Başlayalım"
        case .create: return "İşletme Oluştur"
        case .join: return "Davet Kodu ile Katıl"
        }
    }

    private var headerSubtitle: String {
        switch step {
        case .choice:
            return "Devam etmek için bir işletme oluşturun ya da mevcut birine katılın."
        case .create:
            return "Yeni bir işletme kurun ve ekibinizi davet edin."
        case .join:
            return "Davet kodunu işletme yöneticinizden alabilirsiniz."
        }
    }

    private var choiceStep: some View {
        VStack(spacing: 10) {
            onboardingOption(
                icon: "building.2.fill",
                title: "İşletme Oluştur",
                subtitle: "Yeni bir işletme kur ve ekip üyelerini davet et"
            ) {
                step = .create
            }

            onboardingOption(
                icon: "person.badge.plus",
                title: "Davet Kodu ile Katıl",
                subtitle: "Mevcut bir işletmeye davet kodu ile eriş"
            ) {
                step = .join
            }
        }
    }

    private var createStep: some View {
        VStack(spacing: 12) {
            AppTextField(
                title: "İşletme Adı",
                placeholder: "Örn. Mehmet Usta Oto",
                text: $businessName,
                error: businessNameError
            )
            .id(FormFieldAnchor.businessName.rawValue)

            HStack {
                Spacer()
                Text("\(businessName.count)/50")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            primaryButton(
                title: isCreating ? "Oluşturuluyor..." : "Oluştur",
                isLoading: isCreating,
                isEnabled: !isCreating && FieldValidator.businessNameError(businessName) == nil
            ) {
                onCreate()
            }

            backButton
        }
        .onChange(of: businessName) { _, newValue in
            let filtered = FieldValidator.filteredBusinessName(newValue)
            if filtered != newValue {
                businessName = filtered
            }
        }
    }

    private var joinStep: some View {
        VStack(spacing: 12) {
            AppTextField(
                title: "Davet Kodu",
                placeholder: "AB12-CD34",
                text: $inviteCode,
                error: inviteCodeError
            )

            primaryButton(
                title: isJoining ? "Katılıyor..." : "Katıl",
                isLoading: isJoining,
                isEnabled: !isJoining && FieldValidator.inviteCodeError(inviteCode) == nil
            ) {
                onJoin()
            }

            backButton
        }
        .onChange(of: inviteCode) { _, newValue in
            let filtered = FieldValidator.filteredInviteCodeInput(newValue)
            if filtered != newValue {
                inviteCode = filtered
            }
        }
    }

    private func onboardingOption(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 36, height: 36)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(
        title: String,
        isLoading: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.black.opacity(0.85))
        .disabled(!isEnabled)
    }

    private var backButton: some View {
        Button {
            step = .choice
        } label: {
            Label("Geri", systemImage: "chevron.left")
                .font(.footnote.weight(.semibold))
        }
        .padding(.top, 4)
    }
}

#Preview {
    BusinessOnboardingView(
        businessName: .constant(""),
        inviteCode: .constant(""),
        isCreating: false,
        isJoining: false,
        showsLogout: true,
        onCreate: {},
        onJoin: {},
        onLogout: {}
    )
}
