//
//  LoginView.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import SwiftUI

/// A simple login view
struct LoginView: View {
    
    /// The login view model
    @ObservedObject var loginViewModel: LoginViewModel
    
    /// Dismiss action
    @Environment(\.dismiss) private var dismiss
    
    /// The body
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
            
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Country code:")
                        TextField("Country code", text: Binding(get: {
                            "\(loginViewModel.countryCode)"
                        }, set: {
                            loginViewModel.countryCode = Int($0) ?? 0
                        }))
                    }
                    HStack {
                        Text("Account:")
                        TextField("Account (email, phone, username)", text: $loginViewModel.account)
                            .textContentType(.username)
                    }
                    HStack {
                        Text("Password:")
                        SecureField("Password", text: $loginViewModel.password)
                            .textContentType(.password)
                    }
                    
                    HStack {
                        Text("Access token:")
                        TextField("Access token", text: $loginViewModel.accessToken, axis: .vertical)
                            .lineLimit(8)
//                            .disabled(true)
                            .textSelection(.enabled)
                    }
                    .padding(.bottom)
                }
                
                HStack {
                    Button("Delete token", role: .destructive) {
                        loginViewModel.deleteAccessToken()
                    }
                    .disabled(loginViewModel.accessToken.isEmpty)
                    
                    Button("Save token") {
                        loginViewModel.saveAccessToken()
                    }
                    .disabled(loginViewModel.accessToken.isEmpty)
                    
                    Button("Copy token") {
                        loginViewModel.copyTokenToClipboard()
                    }
                    .disabled(loginViewModel.accessToken.isEmpty)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Button("Login") {
                        Task {
                            if (await loginViewModel.login()) {
                                dismiss()
                            }
                        }
                    }
                    .disabled(loginViewModel.countryCode <= 0 ||
                              loginViewModel.account.isEmpty ||
                              loginViewModel.password.isEmpty)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
     
        
        // MARK: - Alert
        
        .alert(loginViewModel.alertMessage, isPresented: $loginViewModel.presentMessageAlert, actions: {
            Button("OK") {
                loginViewModel.presentMessageAlert = false
            }
        })
    }
}


// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginViewModel: LoginViewModel.preview)
    }
}
