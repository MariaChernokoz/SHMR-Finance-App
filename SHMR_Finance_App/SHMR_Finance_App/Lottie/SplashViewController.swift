//
//  SplashViewController.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 23.07.2025.
//

import UIKit
import Lottie
import SwiftUI

final class SplashViewController: UIViewController {
    private var animationView: LottieAnimationView?
    private let bankAccountService: BankAccountsService
    private let categoriesService: CategoriesService
    private let transactionsService: TransactionsService
    private let networkStatus: AppNetworkStatus
    
    var onFinish: (() -> Void)?

    init(bankAccountService: BankAccountsService, categoriesService: CategoriesService, transactionsService: TransactionsService, networkStatus: AppNetworkStatus) {
        self.bankAccountService = bankAccountService
        self.categoriesService = categoriesService
        self.transactionsService = transactionsService
        self.networkStatus = networkStatus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
                self?.onFinish?()
            }
        }
    }

    private func showMainApp() {
        // Основной экран (TabBarView через UIHostingController)
        let mainVC = UIHostingController(rootView: TabBarView(
            bankAccountService: bankAccountService,
            categoriesService: categoriesService,
            transactionsService: transactionsService,
            networkStatus: networkStatus
        ))
        // Меняем rootViewController с анимацией
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
        }
    }
}
