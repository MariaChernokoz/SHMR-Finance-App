//
//  ConfigCell.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import UIKit

class ConfigCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
//    private lazy var sortButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Сортировать", for: .normal)
//        button.setTitleColor(.accent, for: .normal)
//        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
//        return button
//    }()
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("По дате", for: .normal)
        button.setTitleColor(.accent, for: .normal)
        button.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var dateChangeType: DateChanged?
    
    private var onDateChanged: ((Date, DateChanged) -> Void)?
    private var onSortTapped: (() -> Void)?
    private var onSortSelected: ((SortType) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func resetCell() {
        [titleLabel, valueLabel, datePicker, sortButton].forEach { $0.isHidden = true }
    }

    private func setupViews() {
        selectionStyle = .none
        
        titleLabel.font = .systemFont(ofSize: 17)
        [titleLabel, valueLabel, datePicker, sortButton].forEach { x in
            contentView.addSubview(x)
            x.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sortButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(title: String, date: Date, change: DateChanged, onChange: @escaping (Date, DateChanged) -> Void) {
        resetCell()
        [titleLabel, datePicker].forEach({ $0.isHidden = false })
        titleLabel.text = title
        datePicker.date = date
        self.dateChangeType = change
        self.onDateChanged = onChange
    }
    
//    func configureAsButtonCell(onSortSelected: @escaping (SortType) -> Void) {
//        resetCell()
//        sortButton.isHidden = false
//        self.onSortSelected = onSortSelected
//        
//        sortButton.menu = UIMenu(title: "Сортировка", children: [
//            UIAction(title: "По дате") { [weak self] _ in
//                self?.onSortSelected?(.date)
//            },
//            UIAction(title: "По сумме") { [weak self] _ in
//                self?.onSortSelected?(.amount)
//            }
//        ])
//        sortButton.showsMenuAsPrimaryAction = true
//    }
    
    func configureAsButtonCell(currentSort: SortType, onSortSelected: @escaping (SortType) -> Void) {
        resetCell()
        sortButton.isHidden = false
        self.onSortSelected = onSortSelected

        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: "По дате", state: currentSort == .date ? .on : .off) { [weak self] _ in
                self?.onSortSelected?(.date)
                self?.sortButton.setTitle("По дате", for: .normal)
            },
            UIAction(title: "По сумме", state: currentSort == .amount ? .on : .off) { [weak self] _ in
                self?.onSortSelected?(.amount)
                self?.sortButton.setTitle("По сумме", for: .normal)
            }
        ])
        sortButton.menu = menu
    }

    func configure(title: String, value: String) {
        resetCell()
        [titleLabel, valueLabel].forEach({$0.isHidden = false})
        titleLabel.text = title
        valueLabel.text = value
    }
    
    @objc private func dateChanged() {
        guard let type = dateChangeType else { return }
        onDateChanged?(datePicker.date, type)
    }
    
    @objc private func sortButtonTapped() {
        onSortTapped?()
    }
}

