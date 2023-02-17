//
//  FlightRow.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import SwiftUI

struct FlightRow: View {

    var flight: Flight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verbatim: "_id: \(flight.id) Flight \(flight.carrier)\(flight.number)")
                Image(systemName: "airplane.circle")
                Text(flight.from)
                Image(systemName: "arrow.right")
                Text(flight.to)
            }
        }
    }
}

struct FlightRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                FlightRow(flight: Flight(_id: 1, from: "LHR", to: "SFO", number: 1234, carrier: "UA"))
                FlightRow(flight: Flight(_id: 2, from: "JFK", to: "SEA", number: 7894, carrier: "AS"))
            }
            .navigationTitle("Flights")
        }

    }
}
