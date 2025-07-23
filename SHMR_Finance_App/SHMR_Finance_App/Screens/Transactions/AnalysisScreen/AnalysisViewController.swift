//
//  AnalysisViewController.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 11.07.2025.
//


import UIKit
import PieChart

enum TableViewCellNames {
    static let configCell = "ConfigCell"
    static let transactionCell = "TransactionCell"
}

class AnalysisViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let viewModel: AnalysisViewModel
    private var loadingSpinner: UIActivityIndicatorView?

    init(direction: Direction, categories: [Category]) {
        self.viewModel = AnalysisViewModel(direction: direction, categories: categories)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemGray6
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ConfigCell.self, forCellReuseIdentifier: TableViewCellNames.configCell)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TableViewCellNames.transactionCell)

        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateLoadingState()
            self?.showErrorIfNeeded()
        }
        viewModel.loadTransactions()
        updateLoadingState()
        showErrorIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.title = "Анализ"
        self.parent?.navigationController?.navigationBar.prefersLargeTitles = true
        self.parent?.navigationItem.largeTitleDisplayMode = .always
    }

    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        case 2: return viewModel.transactions.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellNames.configCell, for: indexPath) as! ConfigCell
            if indexPath.row == 0 {
                cell.configure(title: "Период: начало", date: viewModel.firstDate) { [weak self] newDate in
                    self?.viewModel.setStartDate(newDate)
                }
            } else if indexPath.row == 1 {
                cell.configure(title: "Период: конец", date: viewModel.secondDate) { [weak self] newDate in
                    self?.viewModel.setEndDate(newDate)
                }
            } else if indexPath.row == 2 {
                cell.configureAsButtonCell(currentSort: viewModel.sortType) { [weak self] sortType in
                    self?.viewModel.setSortType(sortType)
                }
            } else {
                cell.configure(title: "Сумма", value: viewModel.chosenPeriodSum.formattedAmount + " " + currencySymbol(for: viewModel.accountCurrency))
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            // Создаём PieChartView
            let pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 32, height: 140))
            pieChartView.translatesAutoresizingMaskIntoConstraints = false

            // Формируем данные для PieChartView
            let grouped = Dictionary(grouping: viewModel.transactions, by: { $0.categoryId })
            let maxLabelLength = 12
            let entities: [Entity] = grouped.compactMap { (categoryId, transactions) in
                guard let category = viewModel.categories.first(where: { $0.id == categoryId }) else { return nil }
                let sum = transactions.reduce(Decimal(0)) { $0 + $1.amount }
                let label = category.name.count > maxLabelLength
                    ? String(category.name.prefix(maxLabelLength)) + "…"
                    : category.name
                return Entity(value: sum, label: label)
            }
            // Сортируем по убыванию суммы
            let sortedEntities = entities.sorted { $0.value > $1.value }
            pieChartView.entities = sortedEntities

            // Добавляем PieChartView в ячейку
            cell.contentView.addSubview(pieChartView)
            NSLayoutConstraint.activate([
                pieChartView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                pieChartView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                pieChartView.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 1),
                    pieChartView.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor, multiplier: 1)
            ])

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellNames.transactionCell, for: indexPath) as! TransactionCell
            let transaction = viewModel.transactions[indexPath.row]
            let percentage = viewModel.chosenPeriodSum > 0 ? (transaction.amount / viewModel.chosenPeriodSum * 100) : 0
            let roundedPercentage = NSDecimalNumber(decimal: percentage).rounding(accordingToBehavior: nil)
            let category = viewModel.categories.first(where: { $0.id == transaction.categoryId })
            cell.configure(with: transaction, category: category, percentage: roundedPercentage.decimalValue, currencyCode: viewModel.accountCurrency)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "Операции" : nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44 // высота под выбор дат, сортировку и сумму
        } else if indexPath.section == 1 {
            return 140 // высота под диаграмму
        } else {
            return 60 // высота под транзакцию
        }
    }
    
    private func updateLoadingState() {
        if viewModel.isLoading {
            if loadingSpinner == nil {
                loadingSpinner = UIActivityIndicatorView(style: .large)
                loadingSpinner?.center = view.center
                view.addSubview(loadingSpinner!)
                loadingSpinner?.startAnimating()
            }
        } else {
            loadingSpinner?.stopAnimating()
            loadingSpinner?.removeFromSuperview()
            loadingSpinner = nil
        }
    }
    
    private func showErrorIfNeeded() {
        if let error = viewModel.errorMessage {
            let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
        }
    }
}
