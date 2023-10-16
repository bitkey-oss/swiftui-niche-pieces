import SwiftUI
import SearchableExtensions
import SheetExtensions

struct ContentView: View {
    @State var text = ""
    @State var isPresented = false
    var body: some View {
        Form {
            Section {
                NavigationLink("Searchable") {
                    List {
                        Text("alice")
                        Text("bob")
                        Text("charlie")
                    }
                    .searchable(text: $text)
                    .searchableFocusOnAppear()
                }
            } header: {
                Text("Searchable Extensions")
            }

            Section {
                Button("Open Sheet") {
                    isPresented.toggle()
                }
            } header: {
                Text("Sheet Extensions")
            }
        }
        .sheet(isPresented: $isPresented, detents: [.medium(), .large()]) {
            Text("This is sheet")
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .navigationViewStyle(.stack)
}
