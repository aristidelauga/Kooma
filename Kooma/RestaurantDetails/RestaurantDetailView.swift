
import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    @State private var restaurantDetailVM = RestaurantDetailViewModel()
    @State private var showWebView = false
    var navigationVM: NavigationViewModel
    var restaurant: RestaurantUI
    var names: [String]

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                TextHeading600(text: restaurant.name)
                TextBodyLarge(text: restaurant.address)
                
                MainButton(text: "Open website", maxWidth: 150) {
                    self.showWebView = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            }
            
            HStack {
                TextBodyLarge(text: "Phone Number: \(restaurant.phoneNumber)")
                
                MainButtonIconOnly(symbol: "phone.fill") {
                    self.restaurantDetailVM.makeACall(restaurant.phoneNumber)
                }
            }
            .padding(.vertical, 10)
            
            if !names.isEmpty {
                TextHeading200(text: "Room members who voted for this restaurant:")
                    .padding(.top, 12)
                
                ForEach(self.names, id: \.self) { name in
                    TextBodyMedium(text: "- \(name)")
                }
                .padding(.vertical, 2)
            }
            
            if let scene = self.restaurantDetailVM.lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(12)
                    .padding(.horizontal, 6)
            } else {
                EmptyView()
            }
            
            
            Spacer()
            
                MainButton(text: "Open in Apple Maps", maxWidth: 200) {
                    Task {
                        do {
                            try self.restaurantDetailVM.openInMaps(self.restaurant)
                        } catch {
                            throw error
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationBarBackButtonHidden()
        .onAppear {
            print("path count on RoomDetailView: \(self.navigationVM.path.count)")
            Task(priority: .high, operation: {
                self.restaurantDetailVM.mkMapItem = await self.restaurantDetailVM.searchMapItem(for: restaurant)
                self.restaurantDetailVM.fetchLookAroundPreview()
            })
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.navigationVM.goToRoomDetailsViewFromRestaurantDetails()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .foregroundStyle(.kmYellow)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)
                }
            }
        })
        .sheet(isPresented: $showWebView) {
            if let url = URL(string: restaurant.url ){
                SafariView(url: url)
            }
        }
    }
}

