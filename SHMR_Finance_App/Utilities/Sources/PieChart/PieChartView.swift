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
            animateChartChange()
        }
    }

    // Цвета
    private let segmentColors: [UIColor] = [
        UIColor(red: 0.165, green: 0.91, blue: 0.5, alpha: 1), // Зеленый accent
        UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1), // Жёлтый
        UIColor(red: 0.99, green: 0.38, blue: 0.38, alpha: 1), // Красный
        UIColor(red: 0.36, green: 0.56, blue: 0.99, alpha: 1), // Синий
        UIColor(red: 0.60, green: 0.40, blue: 0.99, alpha: 1), // Фиолетовый
        UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1)  // Серый
    ]

    // Для анимации
    private var animationProgress: CGFloat = 1.0
    private var displayLink: CADisplayLink?
    private var oldEntities: [Entity] = []

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
        let context = UIGraphicsGetCurrentContext()
        let radius = min(rect.width, rect.height) * 0.45
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let lineWidth: CGFloat = 10

        // Первые 5 самых "жирных" категорий + "Остальные"
        var displayEntities = Array(entities.prefix(5))
        if entities.count > 5 {
            let othersValue = entities.dropFirst(5).map { $0.value }.reduce(0, +)
            displayEntities.append(Entity(value: othersValue, label: "Остальные"))
        }

        let total = displayEntities.map { $0.value }.reduce(0, +)
        guard total > 0 else { return }

        // Cегменты
        var startAngle = -CGFloat.pi / 2
        for (index, entity) in displayEntities.enumerated() {
            let value = CGFloat(truncating: entity.value as NSNumber)
            let totalValue = CGFloat(truncating: total as NSNumber)
            let angle = value / totalValue * 2 * .pi * animationProgress
            let endAngle = startAngle + angle

            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = lineWidth
            segmentColors[index % segmentColors.count].setStroke()
            path.stroke()

            startAngle = endAngle
        }

        // Внутри круга
        let legendFont = UIFont.systemFont(ofSize: 7, weight: .regular)
        let legendSpacing: CGFloat = 10
        let legendStartY = center.y - legendSpacing * CGFloat(displayEntities.count) / 2

        for (i, entity) in displayEntities.enumerated() {
            let percent = Int((CGFloat(truncating: entity.value as NSNumber) / CGFloat(truncating: total as NSNumber)) * 100)
            let color = segmentColors[i % segmentColors.count]
            let legendY = legendStartY + CGFloat(i) * legendSpacing

            // Цветная точка
            let dotRect = CGRect(x: center.x - 40, y: legendY, width: 7, height: 7)
            context?.setFillColor(color.cgColor)
            context?.fillEllipse(in: dotRect)

            // Текст
            let text = "\(percent)% \(entity.label)"
            let attributes: [NSAttributedString.Key: Any]
            if #available(iOS 13.0, *) {
                attributes = [
                    .font: legendFont,
                    .foregroundColor: UIColor.label
                ]
            } else {
                attributes = [
                    .font: legendFont,
                    .foregroundColor: UIColor.black
                ]
            }
            let textRect = CGRect(x: center.x - 25, y: legendY, width: 100, height: 16)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    // Анимация (базовая fade + вращение)
    private func animateChartChange() {
        oldEntities = entities
        animationProgress = 0
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc private func updateAnimation() {
        animationProgress += 0.05
        if animationProgress >= 1 {
            animationProgress = 1
            displayLink?.invalidate()
            displayLink = nil
        }
        setNeedsDisplay()
    }
}
