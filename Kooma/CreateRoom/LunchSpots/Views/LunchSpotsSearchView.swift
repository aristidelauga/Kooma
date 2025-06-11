
import SwiftUI
import MapKit

struct LunchSpotsSearchView: View {
    var body: some View {
		VStack(alignment: .leading) {
			TextHeading600(text: "Location")

        }
		.navigationTitle("Lunch spots research")
		.navigationBarTitleDisplayMode(.inline)
		.background(
			Color.kmBeige
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.edgesIgnoringSafeArea(.all)
		)
    }
}

#Preview {
    NavigationView {
    	LunchSpotsSearchView()
    }
}
