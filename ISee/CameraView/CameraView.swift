//
//  CameraView.swift
//  ISee
//
//  Created by Илья Кузнецов on 20.06.2024.
//

import SwiftUI
import AVFoundation
import CoreML

struct CameraView: View {
    
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            CameraViewRepresentable(cameraViewModel: cameraViewModel)
                .ignoresSafeArea()
                .overlay(alignment: .bottom) {
                    VStack {
                        Text(cameraViewModel.recognizedObjects)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding()
//                        ForEach(cameraViewModel.recognizedObjects, id: \.self) { object in
//                            Text(object)
//                                .padding()
//                                .background(Color.black.opacity(0.5))
//                                .foregroundStyle(.white)
//                                .clipShape(.rect(cornerRadius: 10))
//                                .padding()
//                        }
                    }
                }
        }
    }
}

