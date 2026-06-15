//
//  CurioKidsApp.swift
//  CurioKids
//
//  Created by Kirit on 26/05/26.
//

import SwiftUI

@main
struct CurioKidsApp: App {
    
    @AppStorage(AppStorageKeys.hasCompletedOnboarding)
    private var hasCompletedOnboarding = false
    
    @State private var showSplash = true
    @State private var showChildSetup = false
    @State private var showParentPINSetup = false
    
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            showSplash = false
                        }
                    }
                } else {
                    if hasCompletedOnboarding {
                        HomeScreen()
                    } else if showParentPINSetup {
                        ParentPINSetupScreen {
                            hasCompletedOnboarding = true
                        }
                    } else if showChildSetup {
                        ChildProfileSetupScreen {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showParentPINSetup = true
                            }
                        }
                    } else {
                        OnboardingScreen {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                showChildSetup = true
                            }
                        }
                    }
                }
            }
        }
    }
}
