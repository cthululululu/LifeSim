//
//  DoctorsView.swift
//  SamsTownAssetsCopy
//
//  Created by Samuel Jolaoso on 11/14/24.
//

import SwiftUI

struct DoctorsView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Doctors' Office!")
                .font(.title)
                .padding()
            Text("Get health checkups and treatment!")
        }
        .navigationTitle("Doctors")
    }
}

#Preview {
    DoctorsView()
}
