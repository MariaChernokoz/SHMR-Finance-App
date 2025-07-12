//
//  TransactionCell.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let titleLabel = UILabel()
    private let commentLabel = UILabel()
    private let percentageLabel = UILabel()
    private let amountLabel = UILabel()
    private let chevronImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray2
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Methods

    private func setup() {
        [titleLabel, amountLabel, percentageLabel].forEach { x in
            x.font = .systemFont(ofSize: 17)
            x.translatesAutoresizingMaskIntoConstraints = false
        }

        commentLabel.font = .systemFont(ofSize: 15)
        commentLabel.textColor = .gray
        
        let textsVStack = UIStackView(arrangedSubviews: [titleLabel, commentLabel])
        textsVStack.axis = .vertical
        textsVStack.spacing = 2
        textsVStack.translatesAutoresizingMaskIntoConstraints = false
        
        let amountsVStack = UIStackView(arrangedSubviews: [percentageLabel, amountLabel])
        amountsVStack.axis = .vertical
        amountsVStack.spacing = 2
        amountsVStack.alignment = .trailing
        amountsVStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emojiLabel)
        contentView.addSubview(textsVStack)
        contentView.addSubview(amountsVStack)
        contentView.addSubview(chevronImage)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            chevronImage.widthAnchor.constraint(equalToConstant: 11),
            chevronImage.heightAnchor.constraint(equalToConstant: 16),
            chevronImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            textsVStack.widthAnchor.constraint(equalToConstant: 200),
            textsVStack.heightAnchor.constraint(equalToConstant: 40),
            textsVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textsVStack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
            
            amountsVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountsVStack.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -16)
        ])
    }

    func configure(with transaction: Transaction, category: Category?, percentage: Decimal) {
        emojiLabel.text = String(category?.emoji ?? "❓")
        titleLabel.text = category?.name ?? "Категория"
        commentLabel.text = transaction.comment
        commentLabel.isHidden = transaction.comment?.isEmpty ?? true
        percentageLabel.text = "\(percentage) %"
        amountLabel.text = transaction.amount.formattedAmount + " ₽"
    }
}
