//
//  ShakeDetector.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 26.06.2025.
//

import SwiftUI

struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let controller = ShakeViewController()
        controller.onShake = onShake
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}

    class ShakeViewController: UIViewController {
        var onShake: (() -> Void)?

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                onShake?()
            }
        }
    }
}

