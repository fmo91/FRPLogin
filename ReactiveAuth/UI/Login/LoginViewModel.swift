//
//  LoginViewModel.swift
//  ReactiveAuth
//
//  Created by Fernando Ortiz - Parser on 19/06/2022.
//

import Foundation
import Combine

final class LoginViewModel {
    private let authService = AuthService.shared
    private let credentialsValidator = LoginCredentialsValidator()
    private var cancellables: Set<AnyCancellable> = []

    private let emailSubject = CurrentValueSubject<String, Never>("")
    private let passwordSubject = CurrentValueSubject<String, Never>("")
    private let errorReasonSubject = PassthroughSubject<String, Never>()
    private let loggedInSubject = PassthroughSubject<Void, Never>()
    private let credentialsErrorsSubject = CurrentValueSubject<[LoginCredentialsError], Never>([])

    private var credentials: LoginCredentials { .init(email: email, password: password) }
    private var credentialsErrors: [LoginCredentialsError] {
        credentialsErrorsSubject.value
    }

    var email: String {
        get { return emailSubject.value }
        set { emailSubject.send(newValue) }
    }

    var password: String {
        get { return passwordSubject.value }
        set { passwordSubject.send(newValue) }
    }

    var errorReasonPublisher: AnyPublisher<String, Never> {
        errorReasonSubject.eraseToAnyPublisher()
    }

    var loggedInPublisher: AnyPublisher<Void, Never> {
        loggedInSubject.eraseToAnyPublisher()
    }

    var shouldLoginBeEnabledPublisher: AnyPublisher<Bool, Never> {
        credentialsErrorsSubject
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }

    var credentialsErrorsTextPublisher: AnyPublisher<String, Never> {
        credentialsErrorsSubject
            .map { errors in
                errors
                    .map(\.reason)
                    .joined(separator: "\n")
            }
            .eraseToAnyPublisher()
    }

    init() {
        Publishers.CombineLatest(emailSubject, passwordSubject)
            .map { (email, password) in LoginCredentials.init(email: email, password: password) }
            .sink { [weak self] (credentials) in
                let errors = self?.credentialsValidator.validate(credentials: credentials)
                self?.credentialsErrorsSubject.send(errors ?? [])
            }
            .store(in: &cancellables)
    }

    func login() {
        guard credentialsErrors.isEmpty else {
            return
        }

        authService.login(with: credentials)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        switch error {
                        case .wrongPassword:
                            self?.errorReasonSubject.send("Wrong password")
                        case .userNotFound:
                            self?.errorReasonSubject.send("User not found")
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.loggedInSubject.send(())
                }
            )
            .store(in: &cancellables)
    }
}
