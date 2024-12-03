import SwiftUI
import CoreData

struct AssetView: View {
    // Fetching assets from Core Data
    @FetchRequest(
        entity: AssetEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AssetEntity.type, ascending: true)],
        animation: .default)
    private var assets: FetchedResults<AssetEntity>
    
    // Accessing the managed object context from the environment
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            Text("Assets Management")
                .font(.title)
                .padding()

            // List of assets
            List(assets, id: \.objectID) { asset in
                VStack(alignment: .leading) {
                    Text("Asset: \(asset.type ?? "Unknown")")
                        .font(.headline)
                    Text("Value: $\(asset.value, specifier: "%.2f")")
                    Text("Condition: \(asset.condition ?? "Unknown")")
                    Text("Acquired: \(asset.acquisitionDate?.formatted() ?? "Unknown")")
                    
                    // Button to delete the asset
                    Button(action: {
                        deleteAsset(asset: asset)
                    }) {
                        Text("Sell Asset")
                            .foregroundColor(.red)
                    }
                    .padding(.top, 5)
                }
                .padding()
            }
        }
        .navigationTitle("Manage Assets")
        .padding()
    }
    
    // Function to delete asset
    private func deleteAsset(asset: AssetEntity) {
        // Deleting the asset from the managed object context
        viewContext.delete(asset)
        
        do {
            // Save the context to persist changes
            try viewContext.save()
        } catch {
            // Handle error if saving fails
            print("Failed to delete asset: \(error.localizedDescription)")
        }
    }
}


#Preview {
    AssetView()
}
