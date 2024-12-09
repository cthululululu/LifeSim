import SwiftUI

// Define the Final Exam Question structure
struct Question {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
}

let compSciQuestions = [
    // Year 1
    [
        Question(
            question: "Basic unit of a computer?",
            correctAnswer: "Bit",
            incorrectAnswers: ["Byte", "Word", "Nibble"]
        ),
        Question(
            question: "File type for web pages?",
            correctAnswer: "HTML",
            incorrectAnswers: ["CSS", "XML", "JSON"]
        )
    ],
    // Year 2
    [
        Question(
            question: "Type of volatile memory?",
            correctAnswer: "RAM",
            incorrectAnswers: ["ROM", "SSD", "HDD"]
        ),
        Question(
            question: "Binary value of 7?",
            correctAnswer: "111",
            incorrectAnswers: ["011", "101", "110"]
        )
    ],
    // Year 3
    [
        Question(
            question: "Type of loop structure?",
            correctAnswer: "For",
            incorrectAnswers: ["If", "Case", "Switch"]
        ),
        Question(
            question: "SQL data retrieval command?",
            correctAnswer: "Select",
            incorrectAnswers: ["Insert", "Update", "Delete"]
        )
    ],
    // Year 4
    [
        Question(
            question: "Programming for objects?",
            correctAnswer: "OOP",
            incorrectAnswers: ["POP", "AOP", "SOP"]
        ),
        Question(
            question: "Web page styling language?",
            correctAnswer: "CSS",
            incorrectAnswers: ["HTML", "JS", "PHP"]
        )
    ]
]


let historyQuestions = [
    // Year 1
    [
        Question(
            question: "When did the US Civil War end?",
            correctAnswer: "1865",
            incorrectAnswers: ["1870", "1860", "1855"]
        ),
        Question(
            question: "Who wrote the Declaration of Independence?",
            correctAnswer: "Jefferson",
            incorrectAnswers: ["Adams", "Washington", "Franklin"]
        )
    ],
    // Year 2
    [
        Question(
            question: "When was the French Revolution?",
            correctAnswer: "1789",
            incorrectAnswers: ["1790", "1800", "1795"]
        ),
        Question(
            question: "Who was the first President of the United States?",
            correctAnswer: "Washington",
            incorrectAnswers: ["Jefferson", "Adams", "Madison"]
        )
    ],
    // Year 3
    [
        Question(
            question: "When did World War I begin?",
            correctAnswer: "1914",
            incorrectAnswers: ["1915", "1916", "1917"]
        ),
        Question(
            question: "Who discovered America?",
            correctAnswer: "Columbus",
            incorrectAnswers: ["Magellan", "Vespucci", "Cabot"]
        )
    ],
    // Year 4
    [
        Question(
            question: "When did the Berlin Wall fall?",
            correctAnswer: "1989",
            incorrectAnswers: ["1990", "1991", "1988"]
        ),
        Question(
            question: "Who was the British Prime Minister during WWII?",
            correctAnswer: "Churchill",
            incorrectAnswers: ["Thatcher", "Blair", "Chamberlain"]
        )
    ]
]

let biologyQuestions = [
    // Year 1
    [
        Question(
            question: "What is the powerhouse of the cell?",
            correctAnswer: "Mitochondria",
            incorrectAnswers: ["Nucleus", "Ribosome", "Lysosome"]
        ),
        Question(
            question: "What is the chemical formula for water?",
            correctAnswer: "H2O",
            incorrectAnswers: ["CO2", "O2", "NaCl"]
        )
    ],
    // Year 2
    [
        Question(
            question: "What is the main pigment in plants?",
            correctAnswer: "Chlorophyll",
            incorrectAnswers: ["Carotene", "Xanthophyll", "Anthocyanin"]
        ),
        Question(
            question: "What is the basic unit of life?",
            correctAnswer: "Cell",
            incorrectAnswers: ["Tissue", "Organ", "System"]
        )
    ],
    // Year 3
    [
        Question(
            question: "What process converts glucose into energy?",
            correctAnswer: "Respiration",
            incorrectAnswers: ["Photosynthesis", "Glycolysis", "Digestion"]
        ),
        Question(
            question: "What is the largest organ in the human body?",
            correctAnswer: "Skin",
            incorrectAnswers: ["Liver", "Heart", "Kidney"]
        )
    ],
    // Year 4
    [
        Question(
            question: "What is the study of heredity?",
            correctAnswer: "Genetics",
            incorrectAnswers: ["Ecology", "Evolution", "Anatomy"]
        ),
        Question(
            question: "What is the genetic material in cells?",
            correctAnswer: "DNA",
            incorrectAnswers: ["RNA", "Protein", "Lipid"]
        )
    ]
]

func getQuestions(player: PlayerData) -> [Question] {
    var questions: [[Question]] = []
    
    switch player.collegeMajor {
    case "Comp Sci":
        questions = compSciQuestions
    case "History":
        questions = historyQuestions
    case "Biology":
        questions = biologyQuestions
    default:
        print("Error: Unknown major \(player.collegeMajor ?? "nil")")
        return []
    }
    
    if questions.isEmpty || player.collegeYear < 1 || player.collegeYear > questions.count {
        print("Error: Invalid year or empty questions array")
        return []
    }
    
    let yearQuestions = questions[Int(player.collegeYear) - 1]
    
    return yearQuestions.map { question in
        var incorrectAnswers = question.incorrectAnswers
        incorrectAnswers.shuffle()
        
        let numberOfChoices: Int
        switch player.intelligence {
        case 1...6:
            numberOfChoices = 4
        case 7...9:
            numberOfChoices = 3
        case 10:
            numberOfChoices = 2
        default:
            numberOfChoices = 4
        }
        
        var choices = Array(incorrectAnswers.prefix(numberOfChoices - 1)) + [question.correctAnswer]
        choices.shuffle()

        return Question(
            question: question.question,
            correctAnswer: question.correctAnswer,
            incorrectAnswers: choices.filter { $0 != question.correctAnswer }.shuffled()
        )
    }
}


struct FinalExamView: View {
    @State private var examTracker = 0
    @State private var examGrade = 0
    @State private var disableButtons = false
    @State private var examMessage = "Would you like to take your final exam?"
    @Binding var currentSection: GameSection
    var player: PlayerData

    var body: some View {
        let questions = getQuestions(player: player)
        
        return VStack(spacing: 20) {
            Text(examMessage)
                .font(.custom("AvenirNext-Bold", size: 18)) // Adjusted font size
                .foregroundColor(Color.white)
                .padding()
                .frame(maxWidth: 400, minHeight:150)
                .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                .cornerRadius(10)
                .padding(.horizontal)
            
            if player.collegeMajor?.isEmpty == false {
                if examTracker == 0 && examMessage == "Would you like to take your final exam?" {
                    HStack(spacing: 65) {
                        Button(action: {
                            disableButtons = true
                            examMessage = "Good Luck!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                disableButtons = false
                                examMessage = questions[0].question  // Display the first question
                            }
                        }) {
                            Text(disableButtons ? "" : "Yes")
                                .font(.custom("AvenirNext-Bold", size: 22))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding()
                                .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                                .background(disableButtons ? Color.gray : Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .disabled(disableButtons)
                        
                        Button(action: { currentSection = .main }) {
                            Text(disableButtons ? "" : "No")
                                .font(.custom("AvenirNext-Bold", size: 22))
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding()
                                .frame(maxWidth: 125, minHeight: 80, maxHeight: 80)
                                .background(disableButtons ? Color.gray : Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .disabled(disableButtons)
                    }
                } else {
                    examQuestionButtons(player: player, examTracker: $examTracker, examGrade: $examGrade, disableButtons: $disableButtons, examMessage: $examMessage, questions: questions, currentSection: $currentSection)
                }
            } else {
                Text("Please select a major before taking the final exam.")
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: 400)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}


func examQuestionButtons(player: PlayerData, examTracker: Binding<Int>, examGrade: Binding<Int>, disableButtons: Binding<Bool>, examMessage: Binding<String>, questions: [Question], currentSection: Binding<GameSection>) -> some View {
    // Ensure the examTracker value is within the bounds of the questions array
    if examTracker.wrappedValue >= questions.count {
        return AnyView(Text("Error: Question index out of range").foregroundColor(.red))
    }
    
    print("Displaying question \(examTracker.wrappedValue + 1) out of \(questions.count)")
          
    let currentQuestion = questions[examTracker.wrappedValue]
    var answers = [(currentQuestion.correctAnswer, true)]
    answers += currentQuestion.incorrectAnswers.prefix(3).map { ($0, false) }

    // Ensure uniqueness without altering the correct flag
    var uniqueAnswers: [(String, Bool)] = []
    for answer in answers {
        if !uniqueAnswers.contains(where: { $0.0 == answer.0 }) {
            uniqueAnswers.append(answer)
        }
    }

    // Shuffle the answers to randomize their order
    uniqueAnswers.shuffle()

    // Using LazyVGrid for a 2x2 grid layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    return AnyView(LazyVGrid(columns: columns, spacing: 20) {
        ForEach(uniqueAnswers.indices, id: \.self) { index in
            let answer = uniqueAnswers[index]
            Button(action: {
                answerQuestion(correct: answer.1, player: player, examTracker: examTracker, examGrade: examGrade, disableButtons: disableButtons, examMessage: examMessage, questions: questions, currentSection: currentSection)
            }) {
                Text(disableButtons.wrappedValue ? "" : answer.0)
                    .font(.custom("AvenirNext-Bold", size: 22))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
                    .background(disableButtons.wrappedValue ? Color.gray : Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .disabled(disableButtons.wrappedValue)
        }
    })
}


func answerQuestion(correct: Bool, player: PlayerData, examTracker: Binding<Int>, examGrade: Binding<Int>, disableButtons: Binding<Bool>, examMessage: Binding<String>, questions: [Question], currentSection: Binding<GameSection>) {
    print("Starting answerQuestion")
    print("Initial examTracker: \(examTracker.wrappedValue)")
    
    disableButtons.wrappedValue = true
    examMessage.wrappedValue = correct ? "Correct!" : "Wrong!"
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        print("In DispatchQueue - Before increment")
        
        if correct {
            print("Answer is correct")
            examGrade.wrappedValue += 1
        } else {
            print("Answer is wrong")
        }
        
        examTracker.wrappedValue += 1
        print("Updated examTracker: \(examTracker.wrappedValue)")
        
        if examTracker.wrappedValue >= 2 {
            print("Both questions answered")
            
            // Display the final exam result after both questions have been answered
            examMessage.wrappedValue = examGrade.wrappedValue >= 1 ? "You passed the exam!" : "You failed the exam."
            if examGrade.wrappedValue >= 1 {
                player.isEnrolled = true
            }
            examTracker.wrappedValue = 0 // Reset for next interaction
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if examGrade.wrappedValue >= 1 {
                    if player.collegeYear < 4 {
                        player.collegeYear += 1
                        examMessage.wrappedValue = "You are now in Year \(player.collegeYear) of studying \(player.collegeMajor ?? "")."
                        player.isTestTime = false
                        player.time -= 100
                        player.time += 60
                        player.playerAge += 1
                        calculateHealthDecrease(player: player)

                    } else if player.collegeYear >= 4 {
                        examMessage.wrappedValue = "Congratulations! You have Graduated with a Degree in \(player.collegeMajor ?? "")!"
                        player.isGraduate = true
                        player.isTestTime = false
                        player.isEnrolled = false
                        player.time -= 100
                        player.playerAge += 1
                        calculateHealthDecrease(player: player)

                    }
                } else {
                    examMessage.wrappedValue = "You are staying back in Year \(player.collegeYear) of studying \(player.collegeMajor ?? "")."
                    player.time -= 100
                    player.time += 60
                    player.stress += 80
                    player.collegeDebt += 20000
                    player.isTestTime = false
                    player.playerAge += 1
                    calculateHealthDecrease(player: player)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    examGrade.wrappedValue = 0
                    disableButtons.wrappedValue = false
                    examMessage.wrappedValue = "Would you like to take your final exam?"
                    currentSection.wrappedValue = .main
                }
            }
            
        } else {
            // Move to the next question
            examMessage.wrappedValue = questions[examTracker.wrappedValue].question
            disableButtons.wrappedValue = false
            print("Next question: \(examMessage.wrappedValue)")
        }
        print("Ending DispatchQueue")
    }
    print("Ending answerQuestion")
}
func calculateHealthDecrease(player: PlayerData) {
    
    // Calculate additional stress based on total debt
    let debtStress = ((player.collegeDebt + player.debt) / 100000) * 125
    player.stress += debtStress
    
    // Define the stress multiplier based on the player's stress level
    let stressMultiplier: Double
    if player.stress >= 150 {
        stressMultiplier = 3.0 // Severe stress
    } else if player.stress >= 100 {
        stressMultiplier = 2.0 // High stress
    } else if player.stress >= 50 {
        stressMultiplier = 1.0 // Moderate stress
    } else {
        stressMultiplier = 0.5 // Low stress
    }

    // Calculate the health decrease using the formula
    let healthDecrease = log(Double(player.playerAge)) * stressMultiplier * 0.5

    // Update the player's health
    player.health -= healthDecrease

    if player.health < 0 {
        player.health = 0
    }

    player.playerAge += 1

    print("Player's age: \(player.playerAge)")
    print("Health decrease: \(healthDecrease)")
    print("Player's health: \(player.health)")
}
