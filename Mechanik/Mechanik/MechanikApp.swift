//
//  MechanikApp.swift
//  Mechanik
//
//  Created by efe arslan on 20.04.2026.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MechanikApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
        }
    }
}
