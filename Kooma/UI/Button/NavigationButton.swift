//
//  NavigationButton.swift
//  Kooma
//
//  Created by Aristide LAUGA on 14/06/2025.
//

import SwiftUI

struct NavigationButton: View {
	var text: String
    var body: some View {
		TextHeading200(text: text)
			.padding(.vertical, 20)
			.padding(.horizontal, 12)
			.frame(maxWidth: 112, maxHeight: 48)
			.background(
				RoundedRectangle(cornerRadius: 48)
					.foregroundStyle(.kmYellow)
			)

    }
}

#Preview {
	NavigationButton(text: "Submit")
}
