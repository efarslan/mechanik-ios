import SwiftUI
import UIKit

struct LoginView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
        case confirmPassword
        case forgotEmail
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                let isWideLayout = geometry.size.width > 760

                Group {
                    if isWideLayout {
                        HStack(spacing: 0) {
                            formSection
                            heroSection
                        }
                    } else {
                        VStack(spacing: 0) {
                            formSection
                            heroSection
                                .frame(minHeight: 240)
                        }
                    }
                }
                .frame(maxWidth: 980)
                .background(Color.white.opacity(0.94))
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 30, y: 18)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .background(backgroundView.ignoresSafeArea())
        }
        .sheet(isPresented: $viewModel.isForgotPasswordPresented) {
            forgotPasswordSheet
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.94, blue: 0.90),
                    Color(red: 0.82, green: 0.75, blue: 0.60)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.28))
                .frame(width: 280, height: 280)
                .blur(radius: 10)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color(red: 0.33, green: 0.22, blue: 0.12).opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 18)
                .offset(x: 150, y: 240)
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color(red: 0.42, green: 0.28, blue: 0.16))
                .frame(width: 52, height: 52)
                .background(Color(red: 0.98, green: 0.95, blue: 0.88))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.mode == .signIn ? "Tekrar hoş geldiniz" : "Hemen başlayın")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.88))

                Text(viewModel.mode == .signIn
                     ? "Hesabınıza giriş yaparak paneli kullanmaya devam edin."
                     : "Kayıt olduktan sonra işletme bilgilerinizi ekleyerek başlayın.")
                    .font(.callout)
                    .foregroundStyle(Color.black.opacity(0.58))
            }

            authModePicker
            formFields
            footerText
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var authModePicker: some View {
        HStack(spacing: 10) {
            authModeButton(title: "Giriş Yap", mode: .signIn)
            authModeButton(title: "Kayıt Ol", mode: .owner)
        }
        .padding(6)
        .background(Color(red: 0.95, green: 0.93, blue: 0.89))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var formFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputSection(
                title: "E-Posta",
                text: $viewModel.email,
                placeholder: "ornek@email.com",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                field: .email
            )

            passwordField(
                title: "Şifre",
                text: $viewModel.password,
                isVisible: $viewModel.showPassword,
                textContentType: viewModel.mode == .signIn ? .password : .newPassword,
                field: .password
            )

            if viewModel.mode == .signIn {
                Button("Şifremi Unuttum") {
                    viewModel.openForgotPasswordSheet()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.42, green: 0.28, blue: 0.16))
            } else {
                Text("En az 8 karakter, 1 büyük harf ve 1 rakam kullanın.")
                    .font(.footnote)
                    .foregroundStyle(Color.black.opacity(0.55))
            }

            if viewModel.mode == .owner {
                passwordField(
                    title: "Şifre Tekrar",
                    text: $viewModel.confirmPassword,
                    isVisible: $viewModel.showConfirmPassword,
                    textContentType: .newPassword,
                    field: .confirmPassword
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            if let errorMessage = viewModel.errorMessage {
                feedbackLabel(text: errorMessage, background: Color.red.opacity(0.1), foreground: .red)
            }

            if let successMessage = viewModel.successMessage {
                feedbackLabel(text: successMessage, background: Color.green.opacity(0.12), foreground: .green)
            }

            Button {
                hideKeyboard()
                Task {
                    await viewModel.submit(appState: appState)
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(buttonTitle)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            .background(Color(red: 0.18, green: 0.16, blue: 0.14))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .disabled(viewModel.isSubmitting)
            .opacity(viewModel.isSubmitting ? 0.7 : 1)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.mode)
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.14, blue: 0.11),
                    Color(red: 0.36, green: 0.23, blue: 0.12),
                    Color(red: 0.74, green: 0.58, blue: 0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                .padding(24)

            VStack(alignment: .leading, spacing: 14) {
                Text("işletmenizi\ntek ekranda\nyönetin")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Araç servis takibi, iş emirleri, müşteri kayıtları ve anlık raporlarla servis süreçlerini optimize edin.")
                    .font(.callout)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    heroBadge(title: "Servis Takibi")
                    heroBadge(title: "Müşteri Kayıtları")
                }
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, minHeight: 320)
    }

    private var footerText: some View {
        Text("Devam ederek kullanım koşullarını ve gizlilik politikasını kabul etmiş olursunuz.")
            .font(.footnote)
            .foregroundStyle(Color.black.opacity(0.5))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var forgotPasswordSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sifremi Unuttum")
                .font(.title3.bold())

            Text("Şifre sıfırlama bağlantısı için e-posta adresinizi girin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            inputSection(
                title: "E-posta",
                text: $viewModel.forgotEmail,
                placeholder: "ornek@email.com",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                field: .forgotEmail
            )

            if let errorMessage = viewModel.forgotPasswordErrorMessage {
                feedbackLabel(text: errorMessage, background: Color.red.opacity(0.1), foreground: .red)
            }

            if let successMessage = viewModel.forgotPasswordSuccessMessage {
                feedbackLabel(text: successMessage, background: Color.green.opacity(0.12), foreground: .green)
            }

            HStack(spacing: 12) {
                Button("Vazgeç") {
                    viewModel.isForgotPasswordPresented = false
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.black.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    hideKeyboard()
                    Task {
                        await viewModel.resetPassword()
                    }
                } label: {
                    HStack {
                        if viewModel.isForgotPasswordLoading {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(viewModel.isForgotPasswordLoading ? "Gonderiliyor..." : "Mail Gonder")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(Color(red: 0.18, green: 0.16, blue: 0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .disabled(viewModel.isForgotPasswordLoading)
            }
        }
        .padding(24)
    }

    private var buttonTitle: String {
        viewModel.isSubmitting
            ? (viewModel.mode == .signIn ? "Giriş yapılıyor..." : "Hesap oluşturuluyor...")
            : (viewModel.mode == .signIn ? "Giriş Yap" : "Hesap Oluştur")
    }

    private func authModeButton(title: String, mode: LoginViewModel.AuthMode) -> some View {
        Button(title) {
            viewModel.switchMode(to: mode)
        }
        .buttonStyle(.plain)
        .font(.subheadline.weight(.semibold))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(viewModel.mode == mode ? Color.white : Color.clear)
        .foregroundStyle(viewModel.mode == mode ? Color.black.opacity(0.86) : Color.black.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func inputSection(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType,
        textContentType: UITextContentType?,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.72))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .textContentType(textContentType)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(Color(red: 0.97, green: 0.96, blue: 0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(focusedField == field ? Color(red: 0.62, green: 0.44, blue: 0.24) : Color.clear, lineWidth: 1.2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .focused($focusedField, equals: field)
        }
    }

    private func passwordField(
        title: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        textContentType: UITextContentType?,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.72))

            HStack(spacing: 12) {
                Group {
                    if isVisible.wrappedValue {
                        TextField("••••••••", text: text)
                    } else {
                        SecureField("••••••••", text: text)
                    }
                }
                .textInputAutocapitalization(.never)
                .textContentType(textContentType)
                .autocorrectionDisabled()
                .focused($focusedField, equals: field)

                Button {
                    isVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                        .foregroundStyle(Color.black.opacity(0.45))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color(red: 0.97, green: 0.96, blue: 0.94))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(focusedField == field ? Color(red: 0.62, green: 0.44, blue: 0.24) : Color.clear, lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func heroBadge(title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.12))
            .clipShape(Capsule())
    }

    private func feedbackLabel(text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func hideKeyboard() {
        focusedField = nil
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
