//
//  AppDelegate.swift
//  GuidedCaptureSample
//
//  Created by M. Bertan Tarakçıoğlu on 3/29/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
