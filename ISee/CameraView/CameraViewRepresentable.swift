//
//  CameraViewRepresentable.swift
//  ISee
//
//  Created by Илья Кузнецов on 20.06.2024.
//

import Foundation
import SwiftUI

struct CameraViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIViewController()
        let cameraLayer = cameraViewModel.getCameraLayer()
        cameraLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(cameraLayer)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
