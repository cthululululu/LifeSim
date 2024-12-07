//
//  VacationView.swift
//  SamsTownAssetsCopy
//
//  Created by Samuel Jolaoso on 12/2/24.
//

import SwiftUI
import CoreData

struct VacationView: View {
    let vacationResult: [String] = ["You went to the Bahamas", "You went to the Beach", "You went on a Cruise"]
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @ObservedObject var player: PlayerData
    
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        VStack {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                Text("Player Data")
                    .font(.custom("AvenirNext-Bold", size: 42))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding(.top)
            }
            .zIndex(1)
            .frame(height: UIScreen.main.bounds.height * 0.15)
            Text("Want to go on Vacation?")
                .font(.title)
                .padding()
            
            Text("Lets go on Vacation! Make sure you have money!")
            Spacer()
            ZStack {
                Color.blue.ignoresSafeArea()
                VStack (alignment: .leading) {
                    Button(action: {
                        guard player.playerBalance >= 150 else {
                            alertTitle = "Insufficient Balance"
                            alertMessage = "You need more money to go on Vacation"
                            showAlert = true
                            return
                        }
                        
                        player.stress = player.stress - 50 >= 0 ? player.stress - 50 : 0
                        player.playerBalance = player.playerBalance - 150
                        do {
                            try viewContext.save()
                            guard let vacationResult = vacationResult.randomElement() else {return}
                            
                            alertTitle = "Success"
                            alertMessage = vacationResult
                            showAlert = true
                        }
                        catch {
                            
                        }      
                    }, label: {
                        Text("Vacation")
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 80, maxHeight:80)
                            .background(Color.cyan)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    })
                    
                    Spacer()
                        
                }
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)
            
        }
        .alert(alertTitle, isPresented: $showAlert, actions: {
            Button(action: {
                
            }, label: {
                Text("Ok")
            })
        }, message: {
            Text(alertMessage)
        })
        .navigationTitle("Gym")    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Creating a sample PlayerData instance for preview purposes
    let newPlayer = PlayerData(context: context)
    newPlayer.playerName = "Jane"
    newPlayer.gender = "Female"
    newPlayer.intelligence = 8
    newPlayer.playerBalance = 200
    newPlayer.saveDate = Date()
    newPlayer.hasLoan = false
    newPlayer.debt = 0
    newPlayer.hasStock = false
    newPlayer.stockBalance = 0
    
    
    return VacationView(
        player: newPlayer
    )
        .environment(\.managedObjectContext, context)
}
