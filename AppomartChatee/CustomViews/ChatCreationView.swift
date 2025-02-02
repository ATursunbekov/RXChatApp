//
//  ChatCreationView.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 1/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftUICore
import SwiftUI

class ChatCreationView: UIViewController {
    
    var disposeBag = DisposeBag()
    var completion: (String) -> Void
    
    init(completion: @escaping (String) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Create Chat"
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.textColor = .black
        return title
    }()
    
    lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(250)
        }
        
        backView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        backView.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.height.equalTo(44)
        }
        
        backView.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        backView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(25)
        }
    }
    
    func binding() {
        createButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let text = self?.usernameTextField.text {
                    self?.completion(text)
                    self?.dismiss(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}

#if DEBUG
struct MyViewController_Preview: PreviewProvider {
    static var previews: some View {
        ChatCreationView(completion: {val in }).showPreview()
    }
}
#endif
