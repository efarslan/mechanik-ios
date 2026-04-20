//
//  LoginView.swift
//  Mechanik
//
//  Created by efe arslan on 21.04.2026.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: LoginViewModel

    init(appState: AppState) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(appState: appState)
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - TITLE
            Text("Login")
                .font(.largeTitle)
                .bold()
            
            // MARK: - EMAIL
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // MARK: - PASSWORD
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // MARK: - ERROR
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            // MARK: - LOGIN BUTTON
            Button {
                viewModel.login()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .bold()
                }
            }
            .disabled(viewModel.isLoading)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let appState = AppState()
    appState.isLoggedIn = false
    return LoginView(appState: appState)
}
