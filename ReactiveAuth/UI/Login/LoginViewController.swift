//
//  LoginViewController.swift
//  ReactiveAuth
//
//  Created by Fernando Ortiz - Parser on 19/06/2022.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var credentialsErrorsLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!

    let viewModel = LoginViewModel()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.addTarget(self, action: #selector(emailTextChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)

        viewModel.shouldLoginBeEnabledPublisher
            .sink { [weak self] shouldLoginButtonBeEnabled in
                self?.loginButton.isEnabled = shouldLoginButtonBeEnabled
            }
            .store(in: &cancellables)

        viewModel.credentialsErrorsTextPublisher
            .sink { [weak self] credentialsErrorsText in
                self?.credentialsErrorsLabel.text = credentialsErrorsText
            }
            .store(in: &cancellables)

        viewModel.errorReasonPublisher
            .sink { [weak self] errorReason in
                self?.showErrorAlert(for: errorReason)
            }
            .store(in: &cancellables)

        viewModel.loggedInPublisher
            .sink { [weak self] in
                self?.navigationController?.setViewControllers([HomeViewController()], animated: true)
            }
            .store(in: &cancellables)
    }

    @objc private func emailTextChanged() {
        viewModel.email = emailTextField.text ?? ""
    }

    @objc private func passwordTextChanged() {
        viewModel.password = passwordTextField.text ?? ""
    }

    @IBAction private func didTapLoginButton() {
        viewModel.login()
    }
}

private extension LoginViewController {
    func showErrorAlert(for errorReason: String) {
        let alertController = UIAlertController(
            title: errorReason,
            message: nil,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alertController, animated: true, completion: nil)
    }
}
