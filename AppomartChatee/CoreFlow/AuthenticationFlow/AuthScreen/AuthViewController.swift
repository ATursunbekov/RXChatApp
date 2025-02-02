//
//  ViewController.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 30/1/25.
//

import UIKit
import RxSwift
import RxCocoa

class AuthViewController: UIViewController {
    
    private let authView = AuthView()
    private let viewModel = AuthViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = authView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        authView.usernameTextField.rx.text.orEmpty.bind(to: viewModel.username).disposed(by: disposeBag)
        authView.emailTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        authView.passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        authView.loginButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else {
                return
            }
            if self.viewModel.isLogin {
                self.viewModel.login()
            } else {
                self.viewModel.register()
            }
        }).disposed(by: disposeBag)

        authView.registerButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            if viewModel.isLogin {
                self.authView.loginButton.setTitle("Register", for: .normal)
                self.authView.registerButton.setTitle("Press if already have account", for: .normal)
            } else {
                self.authView.loginButton.setTitle("Login", for: .normal)
                self.authView.registerButton.setTitle("Create account", for: .normal)
            }
            self.viewModel.isLogin.toggle()
            self.authView.usernameTextField.isHidden = self.viewModel.isLogin
            self.clearData()
        }).disposed(by: disposeBag)

        viewModel.authResult.subscribe(onNext: { [weak self] success in
            if success {
                self?.navigationController?.pushViewController(MainViewController(), animated: true)
                self?.clearData()
            }
        }).disposed(by: disposeBag)

        viewModel.errorMessage.subscribe(onNext: { [weak self] error in
            self?.showErrorAlert(message: error)
        }).disposed(by: disposeBag)
    }
    
    private func clearData() {
        authView.emailTextField.text = ""
        authView.passwordTextField.text = ""
        authView.usernameTextField.text = ""
    }
}

