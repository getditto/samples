//
//  ProductListItemView.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import SwiftUI

struct ProductListItemView: View {
    var productName: String
    var productDescription: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(productName)
                .bold()
            Text(productDescription)
                .font(.caption)
        }
    }
}

#if DEBUG
struct ProductListItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                Section(header: Text("Drinks")) {
                    ProductListItemView(
                        productName: "Decaf Americano",
                        productDescription: "Decaf Americano with options of Columbian or Italian beans."
                    )
                    ProductListItemView(
                        productName: "Cappucino",
                        productDescription: "A traditional cappuccino has an even distribution of espresso, steamed milk, and foamed milk."
                    )
                }
                Section(header: Text("Entrees")) {
                    ProductListItemView(
                        productName: "Chicken Sandwich",
                        productDescription: "A grilled chicken sandwich with tomatoes, lettuce and mustard."
                    )
                    ProductListItemView(
                        productName: "Roast Beef",
                        productDescription: "A roast beef sandwich with tomatoes, lettuce and mustard."
                    )
                    ProductListItemView(
                        productName: "Fettuccine Alfredo",
                        productDescription: "Fresh fettuccine tossed with butter and Parmesan cheese."
                    )
                }
                Section(header: Text("Desserts")) {
                    ProductListItemView(
                        productName: "Chocolate Ice Cream",
                        productDescription: "Chocolate Ice Cream with chocolate chunks."
                    )
                    ProductListItemView(
                        productName: "Sea Salt Cookie",
                        productDescription: "Mmde from an oatmeal-based dough with raisins."
                    )
                }
            }
            .previewDevice("iPhone 13 Pro")
        }
    }
}
#endif
