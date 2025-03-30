/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The single entry point of the app.
*/

import SwiftUI

@main
struct GuidedCaptureSampleApp: App {
    static let subsystem: String = "com.example.apple-samplecode.guided-capture-sample"
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppDataModel.instance)
        }
    }
}
