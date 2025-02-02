//
//  ChatViewController.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 1/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class ChatViewController: UIViewController {
    
    private let chatView = ChatView()
    private let viewModel: ChatViewModel
    private let disposeBag = DisposeBag()
    private let name: String
    
    init(chatId: String, chatTitle: String) {
        self.viewModel = ChatViewModel(chatId: chatId)
        name = chatTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        navigationItem.title = name
        scrollToBottom()
    }
    
    private func setupBindings() {
        viewModel.messages.bind(to: chatView.tableView.rx.items(cellIdentifier: ChatMessageCell.identifier, cellType: ChatMessageCell.self)) { [weak self] row, message, cell in
            cell.configure(with: message, sender: self?.name ?? "")
        }.disposed(by: disposeBag)
        
        viewModel.messages
            .subscribe { [weak self] val in
                self?.scrollToBottom()
            }
            .disposed(by: disposeBag)
        
        chatView.sendButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self, let senderId = Auth.auth().currentUser?.uid else { return }
            self.viewModel.sendMessage(text: self.chatView.messageTextField.text ?? "", senderId: senderId)
            self.chatView.messageTextField.text = ""
            scrollToBottom()
        }).disposed(by: disposeBag)
        
        chatView.messageTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.chatView.messageTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func scrollToBottom() {
        if viewModel.messages.value.count > 0 {
            chatView.tableView.scrollToRow(at: IndexPath(item: viewModel.messages.value.count-1, section: 0), at: .bottom, animated: true)
        }
    }
}

