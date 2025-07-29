
import Foundation
@preconcurrency import MapKit
import Contacts

@Observable @MainActor
final class RestaurantDetailViewModel {
    
    var lookAroundScene: MKLookAroundScene?
    var mkMapItem: MKMapItem?
    
    func searchMapItem(for restaurant: RestaurantUI) async -> MKMapItem? {
        guard !restaurant.address.isEmpty else {
            return nil
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = restaurant.name
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: restaurant.placemark.latitude,
                                           longitude: restaurant.placemark.longitude),
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )

        let search = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first {
               
                return mapItem
            }
        } catch {
            print("Error searching map item: \(error)")
        }
        return nil
    }
    
    func sendAnalyticsForWebView() {
        ActionEvent.sendAnalytics(event: .openWebView)
    }
    
    func makeACall(_ string: String) {
        guard let url = URL(string: "tel://\(string)"), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
        ActionEvent.sendAnalytics(event: .callRestaurant)
    }
    
    func fetchLookAroundPreview() {
        guard let mkMapItem = self.mkMapItem else { return }
        self.lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: mkMapItem)
            lookAroundScene = try await request.scene
        }
    }
    
    func openInMaps(_ restaurant: RestaurantUI) throws {
        if let item = self.mkMapItem {
            item.name = restaurant.name
            item.openInMaps()
            ActionEvent.sendAnalytics(event: .openAppleMaps)
        }
    }
}
