//
//  DoctorsView.swift
//  SamsTownAssetsCopy
//
//  Created by Samuel Jolaoso on 11/14/24.
//

import SwiftUI

struct DoctorsView: View {
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @ObservedObject var player: PlayerData
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Text("Welcome to the Doctors' Office!")
                .font(.title)
                .padding()
            Text("Get health checkups and treatment!")
            Button(action: {
                var consoltationFee: Double = 0
                var consoltationAdvice = ""
                if player.health > 90 {
                    consoltationFee = 10
                    consoltationAdvice = "Your Healthy!"
                }
                else if player.health > 50 {
                    consoltationFee = 20
                    consoltationAdvice = "You may need to eat better!"
                }
                else {
                    consoltationFee = 30
                    consoltationAdvice = "You may need to eat better and go to the Gym"
                }
                guard player.playerBalance >= consoltationFee else {
                    alertTitle = "Insufficient Balance"
                    alertMessage = "You need more money to go to the gym"
                    showAlert = true
                    return
                }
                player.playerBalance = player.playerBalance - 30
                do {
                    try viewContext.save()
                    alertTitle = "Doctors Advice"
                    alertMessage = consoltationAdvice
                    showAlert = true
                }
                catch {
                    
                }
                
            }, label: {
                Text("Go to Gym - $30")
            })
        }
        
        .alert(alertTitle, isPresented: $showAlert, actions: {
            Button(action: {
                
            }, label: {
                Text("Ok")
            })
        }, message: {
            Text(alertMessage)
        })
        
        .navigationTitle("Doctors")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Creating a sample PlayerData instance for preview purposes
    let newPlayer = PlayerData(context: context)
    newPlayer.playerName = "Jane"
    newPlayer.gender = "Female"
    newPlayer.intelligence = 8
    newPlayer.playerBalance = 100
    newPlayer.saveDate = Date()
    newPlayer.hasLoan = false
    newPlayer.debt = 0
    newPlayer.hasStock = false
    newPlayer.stockBalance = 0
    
    
    return DoctorsView(
        player: newPlayer
    )
        .environment(\.managedObjectContext, context)
}
