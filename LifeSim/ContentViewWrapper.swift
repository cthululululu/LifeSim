import SwiftUI
import UIKit

struct ContentViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ContentView {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ContentView") as! ContentView
        return viewController
    }

    func updateUIViewController(_ uiViewController: ContentView, context: Context) {
        // Update the view controller if needed
    }
}

struct ContentViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWrapper()
    }
}
