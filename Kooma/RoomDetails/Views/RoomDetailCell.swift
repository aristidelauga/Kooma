//
//  RoomDetailCell.swift
//  Kooma
//
//  Created by Aristide LAUGA on 15/07/2025.
//

import SwiftUI

struct RoomDetailCell: View {
    var restaurant: RestaurantUI
//    var voteAction: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                TextHeading200(text: restaurant.name)
                Text("^[\(restaurant.vote) vote](inflect: true)")
                    .font(.bodyMedium)
                    .foregroundStyle(.kmKaki)
            }
            Spacer()
            
        }
    }
}

#Preview {
    RoomDetailCell(
        restaurant: RestaurantUI(
            id: "0df48hf134hf0",
            name: "Central Perk",
            phoneNumber: "+49 612-345-678",
            address: "90 Bedford Street, New-York",
            url: "https://centralparktoursnyc.com/central-perk-coffee-shop/",
            vote: 0)
//        voteAction: {}
    )
}
