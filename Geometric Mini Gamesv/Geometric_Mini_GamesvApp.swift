//
//  Geometric_Mini_GamesvApp.swift
//  Geometric Mini Gamesv

import SwiftUI

@main
struct Geometric_Mini_GamesvApp: App {
    @UIApplicationDelegateAdaptor(GeometricMiniAppDelegate.self) private var appDelegate
    var body: some Scene {
        WindowGroup {
            GeometricMiniGameInitialView()
        }
    }
}
