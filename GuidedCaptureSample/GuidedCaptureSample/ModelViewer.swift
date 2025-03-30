//
//  ModelViewer.swift
//  Object Capture Create
//
//  Created by Bertan on 24.06.2021.
//

import SwiftUI
import SceneKit


struct ModelViewer: UIViewRepresentable {
    private var modelURL: URL
    @Binding private var shouldResetCamera: Bool

    init(modelURL: URL, shouldResetCamera: Binding<Bool>) {
        self.modelURL = modelURL
        self._shouldResetCamera = shouldResetCamera
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let scene = try? SCNScene(url: modelURL)
        scene?.background.contents = UIColor.clear
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear

        // Reset camera position if triggered
        if shouldResetCamera {
            SCNTransaction.begin()
            scnView.pointOfView?.position = SCNVector3(x: 10, y: 0, z: 5)
            scnView.pointOfView?.orientation = SCNVector4(x: 0, y: 1, z: 0, w: .pi/4)
            SCNTransaction.commit()
            shouldResetCamera = false
        }
    }
}

