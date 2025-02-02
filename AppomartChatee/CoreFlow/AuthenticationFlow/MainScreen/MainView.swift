//
//  MainView.swift
//  AppomartChatee
//
//  Created by Alikhan Tursunbekov on 31/1/25.
//

import UIKit
import SnapKit

class MainView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
