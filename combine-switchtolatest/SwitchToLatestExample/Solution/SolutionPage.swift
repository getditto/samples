//
//  SolutionPage.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import SwiftUI

struct SolutionPage: View {

    @ObservedObject var viewModel = SolutionViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Carrier", selection: $viewModel.carrier) {
                    ForEach(DittoManager.carriers, id: \.self) { carrier in
                        Text(carrier)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            List {
                ForEach(viewModel.flights) { flight in
                    FlightRow(flight: flight)
                }
            }
            HStack {
                Text("Live Publishers Count \(viewModel.cancellables.count)")
                    .foregroundColor(.green)
                    .bold()
            }
            .padding()
        }
        .navigationTitle("Problem")
    }
}

struct SolutionPage_Previews: PreviewProvider {
    static var previews: some View {
        SolutionPage()
    }
}
