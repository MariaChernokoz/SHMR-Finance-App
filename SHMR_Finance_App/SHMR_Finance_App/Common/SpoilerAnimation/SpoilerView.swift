//
//  SpoilerView.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 26.06.2025.
//

import SwiftUI

struct SpoilerView: UIViewRepresentable {
    var isOn: Bool

    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()

        let emitterCell = CAEmitterCell()
        emitterCell.contents = makeWhiteDotImage()?.cgImage
        emitterCell.color = UIColor.systemBackground.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 0.4
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 400

        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]

        return emitterView
    }

    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }
    
    func makeWhiteDotImage() -> UIImage? {
        let size = CGSize(width: 2, height: 2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


#Preview {
    struct SpoilerPreview: View {
        @State private var isOn = true

        var body: some View {
            VStack(spacing: 40) {
                ZStack {
                    Text("Hello")
                        .opacity(isOn ? 0 : 1)
                    SpoilerView(isOn: isOn)
                        .frame(width: 60, height: 20)
                        .background(.black)
                }
                Button(isOn ? "Показать текст" : "Скрыть текст") {
                    isOn.toggle()
                }
            }
        }
    }
    return SpoilerPreview()
}
