//
//  LoginCredentialsValidator.swift
//  ReactiveAuth
//
//  Created by Fernando Ortiz - Parser on 19/06/2022.
//

import Foundation

enum LoginCredentialsField {
    case email, password
}

struct LoginCredentialsError {
    let field: LoginCredentialsField
    let reason: String
}

final class LoginCredentialsValidator {
    func validate(credentials: LoginCredentials) -> [LoginCredentialsError] {
        return [
            validatePasswordLength(credentials: credentials),
            validatePasswordContainsANumber(credentials: credentials),
            validateEmailContainsAtSymbol(credentials: credentials),
        ].compactMap { $0 }
    }

    private func validatePasswordLength(credentials: LoginCredentials) -> LoginCredentialsError? {
        guard credentials.password.count >= 6 else {
            return LoginCredentialsError(field: .password, reason: "Password must be 6 characters or longer")
        }

        return nil
    }

    private func validatePasswordContainsANumber(credentials: LoginCredentials) -> LoginCredentialsError? {
        guard credentials.password.contains(where: { $0.isNumber }) else {
            return LoginCredentialsError(field: .password, reason: "Password must contain a number")
        }

        return nil
    }

    private func validateEmailContainsAtSymbol(credentials: LoginCredentials) -> LoginCredentialsError? {
        guard credentials.email.contains("@") else {
            return LoginCredentialsError(field: .email, reason: "Email format is incorrect")
        }

        return nil
    }
}
