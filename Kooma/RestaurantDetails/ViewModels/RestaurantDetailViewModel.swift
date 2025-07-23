
import Foundation
@preconcurrency import MapKit
import Contacts

@Observable @MainActor
final class RestaurantDetailViewModel {
    
    var lookAroundScene: MKLookAroundScene?
    var mkMapItem: MKMapItem?
    private let restaurantService: any GetRestaurantInterface
    
    init(restaurantService: any GetRestaurantInterface = GetRestaurantService()) {
        self.restaurantService = restaurantService
    }
    
    func searchMapItem(for restaurant: RestaurantUI) async -> MKMapItem? {
        await restaurantService.searchMapItem(for: restaurant)
    }
    
    func makeACall(_ string: String) {
        guard let url = URL(string: "tel://\(string)"), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
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
        }
    }
}
