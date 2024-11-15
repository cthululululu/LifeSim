/**
    #CreateCharacterView.swift

    This view allows the player to input their player data and create
    a saved game based off that data. Navigates player to GameView
    after they have successfully created their player.
 */

import SwiftUI
import CoreData

struct CreateCharacterView: View, Hashable {
    @Binding var navigateToGame: Bool
    // Fetches CoreData context from environment
    @Environment(\.managedObjectContext) private var viewContext
    @State private var playerName: String = ""
    @State private var intelligence: Double = 1
    @State private var charisma: Double = 1
    @State private var luck: Double = 1
    @State private var animateGradient: Bool = false
    @State private var selectedGender: String? = nil // State variable for gender selection

    // Function type with updated signature
    var startNewGame: (String, String?, Int, Int, Int) -> Void

    var body: some View {
        
        /// ZStack Nests all other View Stacks in order to implement background color than spans whole view
        ZStack {
            
            ///#======= DEFINES BACKGROUND COLOR ANIMATION ============
            LinearGradient(colors: [Color.indigo, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(animateGradient ? 45 : 0))
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

            /// VStack Nests all input UI content
            VStack {
                
                ///#============ TITLE CONTENT ============
                Text("LifeSim")
                    .font(.custom("AvenirNext-Bold", size: 32))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()

                ///#============ NAME INPUT ============
                HStack {
                    Text("Name")
                        .font(.custom("AvenirNext-Bold", size: 20))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                    TextField("Enter Name Here", text: $playerName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                
                ///#============ GENDER INPUT ============
                HStack {
                    Button(action: {
                        selectedGender = "Male"
                    }) {
                        Text("♂    ")
                            .padding()
                            // Changes background color of Button IF it is currently clicked
                            .background(selectedGender == "Male" ? Color.white : Color.blue)
                            // Changes text font color of Button IF it is currently clicked
                            .foregroundColor(selectedGender == "Male" ? Color.blue : Color.white)
                            .cornerRadius(10)
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .shadow(radius: 5)
                            .padding()
                    }

                    Button(action: {
                        selectedGender = "Female"
                    }) {
                        Text("♀    ")
                            .padding()
                            // Changes background color of Button IF it is currently clicked
                            .background(selectedGender == "Female" ? Color.white : Color.pink)
                            // Changes text font color of Button IF it is currently clicked
                            .foregroundColor(selectedGender == "Female" ? Color.pink : Color.white)
                            .cornerRadius(10)
                            .font(.custom("AvenirNext-Bold", size: 22))
                            .shadow(radius: 5)
                            .padding()
                        
                    }
                }
                .padding()

                
                ///#============ DISPLAYS STYLE POINTS LEFT ============
                Text("Skill Points Left: \(Int(18 - sumOfAttributes()))")
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()

                
                /// VStack nests all 3 rows of Slider inputs
                VStack {
                    
                    ///#============ INTELLIGENCE INPUT ============
                    HStack {
                        Text("Intelligence       \(Int(intelligence))")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                        Slider(value: $intelligence, in: 1...10, step: 1)
                            .padding(.horizontal)
                            .accentColor(Color.yellow)
                            .shadow(radius:5)
                            .onChange(of: intelligence) { _ in validateSlider() }
                    }

                    ///#============ CHARISMA INPUT ============
                    HStack {
                        Text("Charisma           \(Int(charisma))")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                        Slider(value: $charisma, in: 1...10, step: 1)
                            .padding(.horizontal)
                            .accentColor(Color.mint)
                            .shadow(radius:5)
                            .onChange(of: charisma) { _ in validateSlider() }
                    }
                    
                    ///#============ LUCK INPUT ============
                    HStack {
                        Text("Luck                    \(Int(luck))")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                        Slider(value: $luck, in: 1...10, step: 1)
                            .padding(.horizontal)
                            .accentColor(Color.indigo)
                            .shadow(radius:5)
                            .onChange(of: luck) { _ in validateSlider() }
                    }
                }
                .padding()

                ///#============ SUBMIT BUTTON ============
                Button(action: {
                    startNewGame(playerName, selectedGender, Int(intelligence), Int(charisma), Int(luck))
                    navigateToGame = true
                }) {
                    Text("Begin Life")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundColor(Color.white)
                        .shadow(radius: 5)
                        .padding()
                        .frame(maxWidth: 150, minHeight: 60, maxHeight:60)
                        .background(playerName.count < 3 || playerName.count > 12 || sumOfAttributes() < 18 || selectedGender == nil ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                
                /// Submit Button Disabled IF:
                /// - Player name is NOT between 3-12 characters
                /// - Sum of skill points is NOT 18 or greater
                /// - Neither Gender has been selected
                .disabled(playerName.count < 3 || playerName.count > 12 || sumOfAttributes() < 18 || selectedGender == nil)
                
                
            }
        }
    }
        
    // Slider Validation Function Ensures Skill Points Stays at 18 or Below
    func validateSlider() {
        if sumOfAttributes() >= 19 {
            
            // If over 18, Subtract points to keep it under 18
            if intelligence > 1 {
                intelligence -= 1
            }
            if charisma > 1 {
                charisma -= 1
            }
            if luck > 1 {
                luck -= 1
            }
        }
    }

    // Returns the sum of all skill points from the Slider inputs
    func sumOfAttributes() -> Double {
        return intelligence + charisma + luck
    }

    // Conforms to Equatable Protocol
    static func == (lhs: CreateCharacterView, rhs: CreateCharacterView) -> Bool {
        return lhs.navigateToGame == rhs.navigateToGame
    }

    // Conforms to Hashable Protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(navigateToGame)
    }
}


// For XCode Preview Purposes only:
struct CreateCharacterView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return CreateCharacterView(
            navigateToGame: .constant(false),
            startNewGame: { playerName, gender, intelligence, charisma, luck in
                // Sample implementation
            }
        )
        .environment(\.managedObjectContext, context)
    }
}
