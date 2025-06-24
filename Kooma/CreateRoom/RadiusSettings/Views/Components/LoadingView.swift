//
//  LoadingView.swift
//  Kooma
//
//  Created by Aristide LAUGA on 24/06/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
		ZStack {
			Color.black.opacity(0.3)
			ProgressView("Loading restaurants...")
				.progressViewStyle(CircularProgressViewStyle())
		}
    }
}

#Preview {
    LoadingView()
}
