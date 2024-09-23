//
//  PhoneAppDonateView.swift
//  LibreWrist
//
//  Created by Peter Müller on 01.08.24.
//

import SwiftUI
import StoreKit

struct PhoneAppDonateView: View {
    
    private let productIDs = [
        "librewrist_4_99",
        "librewrist_9_99",
        "librewrist_24_99",
        "librewrist_49_99"
    ]
    
    var body: some View {
        //        ScrollView {
        VStack (spacing: 15) {
            Image("coffeeBeans")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            Text("If you like this app, buy the developer quality coffee beans!\n🤝☕️")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            //            Link(destination: URL(string: "https://paypal.me/lovemyhusky")!) {
            //                Text("🐶 PayPal.Me")
            //                    .frame(width: 200, height: 50)
            //                    .foregroundColor(.primary)
            //                    .background(.primary)
            //                    .cornerRadius(10)
            //            }
            
            ForEach(productIDs, id: \.self) { id in
                ProductView(id: id)
                    .productViewStyle(CustomProductStyle())
                
            }
        }
        //        }
    }
}



struct CustomProductStyle: ProductViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
        case .loading:
            ProgressView()
        case .success(let product):
            Button {
                configuration.purchase()
            } label: {
                VStack {
//                    Text(verbatim: "\(product.displayName) \(product.displayPrice)")
                    Text(verbatim: product.displayName)
                    Text(verbatim: product.displayPrice)
//                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
            
            .buttonStyle(.borderedProminent)
            
            
        default:
            Text("Something went wrong...")
        }
    }
}

#Preview {
    PhoneAppDonateView()
}
