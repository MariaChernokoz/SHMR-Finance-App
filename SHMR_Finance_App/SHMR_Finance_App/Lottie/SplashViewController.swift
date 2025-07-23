//
//  SplashViewController.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 23.07.2025.
//

import UIKit
import Lottie
import SwiftUI

class SplashViewController: UIViewController {
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let animationView = LottieAnimationView(name: "upload") 
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        self.animationView = animationView

        animationView.play { [weak self] finished in
            if finished {
                self?.showMainApp()
            }
        }
    }

    private func showMainApp() {
        // Основной экран (TabBarView через UIHostingController)
        let mainVC = UIHostingController(rootView: TabBarView())
        
        // Меняем rootViewController с анимацией
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }
}
