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
    
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("По дате", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        button.layer.cornerRadius = 8
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var onDateChanged: ((Date) -> Void)? //
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
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, date: Date, onChange: @escaping (Date) -> Void) {
        resetCell()
        [titleLabel, datePicker].forEach({ $0.isHidden = false })
        titleLabel.text = title
        datePicker.date = date
        self.onDateChanged = onChange
    }
    
    func configureAsButtonCell(currentSort: SortType, onSortSelected: @escaping (SortType) -> Void) {
        resetCell()
        sortButton.isHidden = false
        titleLabel.isHidden = false
        titleLabel.text = "Сортировка"
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
        onDateChanged?(datePicker.date,)
    }
    
    @objc private func sortButtonTapped() {
        onSortTapped?()
    }
}

