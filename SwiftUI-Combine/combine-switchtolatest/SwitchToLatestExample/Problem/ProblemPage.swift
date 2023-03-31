//
//  ProblemPage.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import SwiftUI

struct ProblemPage: View {

    @ObservedObject var viewModel = ProblemViewModel()

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
                    .foregroundColor(.red)
                    .bold()
            }
            .padding()
        }
        .navigationTitle("Problem")
    }
}

struct ProblemPage_Previews: PreviewProvider {
    static var previews: some View {
        ProblemPage()
    }
}
