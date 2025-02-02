//
//  ChatMessageCell.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 2/2/25.
//

import UIKit
import FirebaseAuth

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var senderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0 
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8, weight: .light)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(mainView)
        mainView.addSubview(senderLabel)
        mainView.addSubview(messageLabel)
        mainView.addSubview(dateLabel)
        
        mainView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.greaterThanOrEqualToSuperview().offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
        
        senderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(senderLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(with message: MessageModel, sender: String) {
        messageLabel.text = message.text
        dateLabel.text = formattedDate(date: message.date)
        
        let isCurrentUser = message.senderId == Auth.auth().currentUser?.uid
        senderLabel.text = isCurrentUser ? "Me:" : "\(sender):"
        
        mainView.backgroundColor = isCurrentUser ? .systemGreen : .systemBlue
        mainView.layer.maskedCorners = isCurrentUser ?
            [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner] :
            [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        
        mainView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            if isCurrentUser {
                make.trailing.equalToSuperview().offset(-10)
            } else {
                make.leading.equalToSuperview().offset(10)
            }
        }
    }
    
    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
