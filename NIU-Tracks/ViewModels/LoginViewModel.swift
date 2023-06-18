//
//  LoginViewModel.swift
//  NIU-Tracks
//
//  Created by Andre Albach on 17.06.23.
//

import AppKit
import Foundation
import NiuAPI
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier, category: "LoginViewModel")

/// The login view model
@MainActor
final class LoginViewModel: ObservableObject {
    
    /// The country code to use to log in
    @Published var countryCode: Int = UserDefaults.standard.countryCode {
        didSet {
            UserDefaults.standard.countryCode = countryCode
        }
    }
    /// The account to use to log in
    @Published var account: String = UserDefaults.standard.account ?? "" {
        didSet {
            UserDefaults.standard.account = account
        }
    }
    /// The password to use to log in
    @Published var password: String = ""
    
    /// The stored access token, if there is one
    @Published var accessToken: String = UserDefaults.standard.accessToken ?? ""
    
    /// Indicator, if the alert which shows a message sould be displayed
    @Published var presentMessageAlert: Bool = false {
        didSet {
            if !presentMessageAlert {
                alertMessage = ""
            }
        }
    }
    /// The message displayed in the alert
    @Published private(set) var alertMessage: String = "" {
        didSet {
            guard !alertMessage.isEmpty else { return }
            presentMessageAlert = true
        }
    }
    
    
    // MARK: - User intends
    
    /// Will do the login with the provided data
    func login() async -> Bool {
        do {
            let loginResponse = try await NiuAPI.login(with: account, password: password, countryCode: countryCode)
            UserDefaults.standard.accessToken = loginResponse.token.access_token
            DispatchQueue.main.async {
                self.accessToken = loginResponse.token.access_token
            }
            return true
        } catch {
            if let error = error as? NiuAPI.Errors {
                logger.error("\(error.description, privacy: .public)")
            } else {
                logger.error("\(error.localizedDescription, privacy: .public)")
            }
            DispatchQueue.main.async {
                self.alertMessage = String(localized: "There was an error with your login. Please check account and password.")
            }
            return false
        }
    }
    
    /// Will delete the stored access token
    func deleteAccessToken() {
        UserDefaults.standard.accessToken = nil
        accessToken = ""
    }
    
    /// Will save the entered access token
    func saveAccessToken() {
        UserDefaults.standard.accessToken = accessToken
    }
    
    /// Will copy the access token to the pasteboard
    func copyTokenToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(accessToken, forType: .string)
    }
}


// MARK: - Preview data

extension LoginViewModel {
    /// Preview data
    static let preview: LoginViewModel = {
        let vm = LoginViewModel()
        vm.countryCode = 49
        vm.account = "01711234567"
        vm.password = "mySecretPassword"
        vm.accessToken = ""
        return vm
    }()
}
