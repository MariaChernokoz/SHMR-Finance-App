//
//  AnalysisViewControllerWrapper.swift
//  SHMR_Finance_App
//
//  Created by Chernokoz on 12.07.2025.
//

import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction
    let categories: [Category]

    init(direction: Direction, categories: [Category]) {
        self.direction = direction
        self.categories = categories
    }
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController(direction: direction, categories: categories)
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}
