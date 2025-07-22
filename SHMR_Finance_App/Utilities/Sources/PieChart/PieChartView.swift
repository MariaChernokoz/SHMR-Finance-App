//
//  PieChartView.swift
//  Utilities
//
//  Created by Chernokoz on 22.07.2025.
//

import UIKit

public class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    // Цвета для 6 сегментов
    private let segmentColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemGray
    ]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    public override func draw(_ rect: CGRect) {
        guard !entities.isEmpty else { return }
        // 1. Суммируем значения
        let total = entities.map { $0.value }.reduce(0, +)
        guard total > 0 else { return }

        // 2. Готовим данные: первые 5 + "Остальные"
        var displayEntities = Array(entities.prefix(5))
        if entities.count > 5 {
            let othersValue = entities.dropFirst(5).map { $0.value }.reduce(0, +)
            displayEntities.append(Entity(value: othersValue, label: "Остальные"))
        }

        // 3. Рисуем сегменты
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.4
        var startAngle = -CGFloat.pi / 2

        for (index, entity) in displayEntities.enumerated() {
            let angle = CGFloat(truncating: entity.value as NSNumber) / CGFloat(truncating: total as NSNumber) * 2 * .pi
            let endAngle = startAngle + angle

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            segmentColors[index % segmentColors.count].setFill()
            path.fill()

            startAngle = endAngle
        }

        // 4. Нарисуй легенду (можно упростить, потом доработать)
        // ...
    }
}
