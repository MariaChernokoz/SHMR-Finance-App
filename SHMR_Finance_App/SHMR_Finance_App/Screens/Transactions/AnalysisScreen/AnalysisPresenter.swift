//
//  AnalysisPresenter.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import Foundation
import UIKit

@MainActor
class AnalysisPresenter: NSObject {
    
    weak var viewController: AnalysisViewController?
    let transactionsService = TransactionsService.shared
    
    var firstDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    var secondDate = Date.now
    var lastDateChanged: DateChanged = .first
    var chosenPeriodSum: Decimal = 0
    var sortType: SortType = .date
    
    private(set) var transactions: [Transaction] = []
    let categories: [Category]
    
    let direction: Direction
    
    init(direction: Direction, categories: [Category]) {
        self.direction = direction
        self.categories = categories
    }
    
    func viewDidLoad() {
        Task {
            await loadTransactions(direction: direction)
        }
    }
    
    func attach(viewController: AnalysisViewController) {
        self.viewController = viewController
    }
    
    func loadTransactions(direction: Direction) async {
        let calendar = Calendar.current
        var firstDay = calendar.startOfDay(for: firstDate)
        var secondDay = calendar.endOfDay(for: secondDate)!
        
        switch lastDateChanged {
        case .first:
            if firstDay > secondDay {
                secondDate = calendar.endOfDay(for: firstDate)!
                secondDay = secondDate
            }
        case .second:
            if secondDay < firstDay {
                firstDate = calendar.startOfDay(for: secondDate)
                firstDay = firstDate
            }
        }
        
        let interval = DateInterval(start: firstDay, end: secondDay)
        
        do {
            let allTransactions = try await transactionsService.getTransactionsOfPeriod(interval: interval)
            // Фильтрация по direction через категории
            let filteredTransactions = allTransactions.filter { transaction in
                if let category = categories.first(where: { $0.id == transaction.categoryId }) {
                    return category.isIncome == direction
                }
                return false
            }

            var sum: Decimal = 0
            filteredTransactions.forEach { transaction in
                sum += transaction.amount
            }

            DispatchQueue.main.async {
                self.transactions = filteredTransactions
                self.chosenPeriodSum = sum
                self.sort(by: self.sortType)
            }
        } catch {
            print("Ошибка загрузки: \(error)")
        }
        
        viewController?.tableView.reloadData()
    }
    
    func sort(by parameter: SortType) {
        switch parameter {
        case .date:
            transactions.sort(by: { $0.transactionDate > $1.transactionDate })
        case .amount:
            transactions.sort(by: { $0.amount > $1.amount })
        }
        
        viewController?.tableView.reloadData()
    }
}


extension AnalysisPresenter: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 3 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        case 2: return transactions.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellNames.configCell, for: indexPath) as! ConfigCell
            if indexPath.row == 0 {
                cell.configure(title: "Период: начало", date: firstDate, change: .first) { newDate, change in
                    self.firstDate = newDate
                    self.lastDateChanged = change
                    Task {
                        await self.loadTransactions(direction: self.direction)
                    }
                }
            } else if indexPath.row == 1 {
                cell.configure(title: "Период: конец", date: secondDate, change: .second) { newDate, change in
                    self.secondDate = newDate
                    self.lastDateChanged = change
                    Task {
                        await self.loadTransactions(direction: self.direction)
                    }
                }
            } else if indexPath.row == 2 {
                cell.configureAsButtonCell(currentSort: self.sortType) { [weak self] sortType in
                    self?.sortType = sortType
                    self?.sort(by: sortType)
                }
            } else {
                cell.configure(title: "Сумма", value: chosenPeriodSum.formattedAmount + " ₽")
            }
            return cell
            
        } else if indexPath.section == 1 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            let label = UILabel()
            label.text = "круговая диаграмма"
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ])
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellNames.transactionCell, for: indexPath) as! TransactionCell
            let transaction = transactions[indexPath.row]
            var percentage = (transaction.amount / chosenPeriodSum * 100)
            var roundedPercentage = Decimal()
            NSDecimalRound(&roundedPercentage, &percentage, 0, .plain)
            let category = categories.first(where: { $0.id == transaction.categoryId })
            cell.configure(with: transaction, category: category, percentage: roundedPercentage)
            return cell
        }
    }
}


extension AnalysisPresenter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 50
        case 1: return 120
        case 2: return 60
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "Операции" : nil
    }
}
