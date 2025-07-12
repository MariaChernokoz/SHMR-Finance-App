//
//  AnalysisViewController.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//

import Foundation
import UIKit

enum TableViewCellNames {
    static let configCell = "ConfigCell"
    static let transactionCell = "TransactionCell"
}

class AnalysisViewController: UIViewController {
    
    private var presenter: AnalysisPresenter?
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    let direction: Direction
    let categories: [Category]
    
    init(direction: Direction, categories: [Category]) {
        self.direction = direction
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = AnalysisPresenter(direction: direction, categories: categories)

        view.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.systemGray6
        
        presenter?.attach(viewController: self)
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.parent?.navigationItem.title = "Анализ"
        
        self.parent?.navigationController?.navigationBar.isTranslucent = true
        self.parent?.navigationController?.navigationBar.prefersLargeTitles = true
        self.parent?.navigationItem.largeTitleDisplayMode = .always
        self.parent?.navigationController?.navigationBar.backgroundColor = .clear
        
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.dataSource = presenter
        tableView.delegate = presenter
        tableView.register(ConfigCell.self, forCellReuseIdentifier: TableViewCellNames.configCell)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TableViewCellNames.transactionCell)
    }
}
