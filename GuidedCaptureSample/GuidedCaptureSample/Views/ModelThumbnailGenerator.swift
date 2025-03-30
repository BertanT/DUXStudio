//
//  ModelThumbnailGenerator.swift
//  GuidedCaptureSample
//
//  Created by M. Bertan Tarakçıoğlu on 3/29/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SceneKit

struct ModelThumbnailGenerator {
    static func generateThumbnail(from modelURL: URL) -> UIImage? {
        let scene = try! SCNScene(url: modelURL, options: nil)
        let scnView = SCNView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear
        
        // Create a snapshot of the scene
        return scnView.snapshot()
    }
}
