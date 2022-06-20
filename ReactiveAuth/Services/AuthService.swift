//
//  AuthService.swift
//  ReactiveAuth
//
//  Created by Fernando Ortiz - Parser on 19/06/2022.
//

import Foundation
import Combine
import CombineExt

enum LoginError: Error {
    case userNotFound
    case wrongPassword
}

final class AuthService {
    private static let testCredentials = LoginCredentials(email: "test@parserdigital.com", password: "123456")

    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    var currentValuePublisher: AnyPublisher<User?, Never> {
        currentUserSubject.eraseToAnyPublisher()
    }
    var currentUser: User? {
        currentUserSubject.value
    }

    static let shared = AuthService()

    func login(with credentials: LoginCredentials) -> AnyPublisher<User, LoginError> {
        return AnyPublisher { subscriber in
            if credentials.email != Self.testCredentials.email {
                subscriber.send(completion: .failure(.userNotFound))
            } else if credentials.password != Self.testCredentials.password {
                subscriber.send(completion: .failure(.wrongPassword))
            } else {
                subscriber.send(User(email: credentials.email, password: credentials.password))
            }

            return AnyCancellable {}
        }
        .handleEvents(receiveOutput: { user in
            self.currentUserSubject.send(user)
        })
        .eraseToAnyPublisher()
    }
}
