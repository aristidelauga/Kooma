//
//  KoomaApp.swift
//  Kooma
//
//  Created by Aristide LAUGA on 08/06/2025.
//

import SwiftUI

@main
struct KoomaApp: App {
	@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some Scene {
        WindowGroup {
			NavigationStack {
				if hasSeenOnboarding {
					CreateRoomView()
				} else {
					OnboardingStepOneView()
				}
			}
        }
    }
}
