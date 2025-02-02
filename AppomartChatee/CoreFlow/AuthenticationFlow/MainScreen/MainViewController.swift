//
//  MainViewController.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 30/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class MainViewController: UIViewController {
    
    private let mainView = MainView()
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchChats()
    }
    
    private func setupNavigationBar() {
        title = "Chats"
        
        let logoutButton = UIBarButtonItem(
            title: "Exit",
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        navigationItem.leftBarButtonItem = logoutButton
        
        let createChatButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createChat)
        )
        navigationItem.rightBarButtonItem = createChatButton
    }
    
    private func setupBindings() {
        viewModel.chats
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: ChatCell.identifier,
                cellType: ChatCell.self
            )) { index, chat, cell in
                cell.configure(with: chat)
            }
            .disposed(by: disposeBag)
        
        mainView.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else {return}
                let data = self.viewModel.chats.value[indexPath.row]
                self.navigationController?.pushViewController(ChatViewController(chatId: data.id, chatTitle: data.name), animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] error in
            self?.showErrorAlert(message: error)
        }).disposed(by: disposeBag)
    }
    
    @objc private func logout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            showErrorAlert(message: "Failed to logout: \(error.localizedDescription)")
        }
    }
    
    @objc private func createChat() {
        let createChatVC = ChatCreationView(completion: { [weak self] val in
            self?.viewModel.startChat(otherUsername: val) { [weak self] chatId, username in
                if let chatId = chatId, let username = username {
                    self?.navigationController?.pushViewController(ChatViewController(chatId: chatId, chatTitle: username), animated: false)
                    print("Chat started successfully with ID: \(chatId)")
                } else {
                    self?.showErrorAlert(message: "Did'nt Find User or chat already exist")
                    print("Failed to start chat.")
                }
            }
        })
        createChatVC.modalPresentationStyle = .overFullScreen
        present(createChatVC, animated: false)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
