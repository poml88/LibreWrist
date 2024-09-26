//
//  WatchAppSettings2View.swift
//  LibreWristWatch Watch App
//
//  Created by Peter Müller on 30.08.24.
//

import SwiftUI
import StoreKit


struct WatchAppDonateView: View {
    
    private let productIDs = [
        "librewrist_4_99_a",
        "librewrist_9_99_a",
        "librewrist_24_99_a",
        "librewrist_49_99_a"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Buy the developer quality coffee beans!\n🤝☕️")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                
                
                //                Text("paypal.me/lovemyhusky")
                //                .font(.caption)
                //                    .frame(maxWidth: 200, maxHeight: 50)
                //                    .foregroundColor(.black)
                //                    .background(.green)
                //                    .cornerRadius(10)
                
//                StoreView(ids: productIDs)
//                .productViewStyle(CustomProductStyle())
//                .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                
                
                                ForEach(productIDs, id: \.self) { id in
                                    ProductView(id: id)
                                        .productViewStyle(CustomProductStyle())
                                }
                            
                
                
            }
            .padding(.top, -20)
        }
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
                    Text(verbatim: "\(product.displayName) \(product.displayPrice)")
                        .font(.caption2)
                }
            }
            .buttonStyle(.borderedProminent)
        default:
            Text("Something went wrong...")
        }
    }
}
    
#Preview {
    WatchAppDonateView()
}
