//
//  ModelCompleteView.swift
//  GuidedCaptureSample
//
//  Created by M. Bertan Tarakçıoğlu on 3/29/25.
//  Copyright © 2025 Apple. All rights reserved.
//

//
//  Uploader.swift
//  duxtest
//
//  Created by M. Bertan Tarakçıoğlu on 3/29/25.
//

import SwiftUI
import SceneKit
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct ModelCompleteView: View {
    let modelFile: URL
    let endCaptureCallback: () -> Void
    @State private var shouldResetCamera = false
    @State private var isUploading = false
    

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Model viewer takes the full space
                ModelViewer(modelURL: modelFile, shouldResetCamera: $shouldResetCamera)
                    .onAppear {
                        shouldResetCamera.toggle()
                    }
                
                // Overlay panel at the bottom
                VStack(spacing: 16) {
                    Text("Say hello to your newborn duck!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your 3D model has been successfully processed and is ready to upload.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination:
                                    UploadView(modelFile: modelFile, endCaptureCallback: endCaptureCallback)
                        .navigationBarBackButtonHidden()
                    ) {
                        Text("Start Upload")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isUploading)
                    .padding(.top, 8)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Material.regular)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}
