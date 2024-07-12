import SwiftUI
import MapKit

struct AddStopView: View {
    @Binding var stops: [Stop]
    @Binding var isPresented: Bool
    @State private var newStopAddress: String = ""
    @State private var suggestions: [MKMapItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Maps", text: $newStopAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: newStopAddress) { query in
                        fetchSuggestions(for: query)
                    }
                
                if !suggestions.isEmpty {
                    List(suggestions, id: \.self) { suggestion in
                        VStack(alignment: .leading) {
                            Text(suggestion.name ?? "Unknown place")
                                .font(.headline)
                            Text(suggestion.placemark.title ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .onTapGesture {
                            addStop(suggestion)
                            isPresented = false
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Add Stop")
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func addStop(_ mapItem: MKMapItem?) {
        guard let mapItem = mapItem else { return }
        let newStop = Stop(name: mapItem.name ?? newStopAddress, icon: "mappin.and.ellipse", color: .red)
        stops.append(newStop)
        newStopAddress = ""
        suggestions.removeAll()
    }
    
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error fetching suggestions: \(error.localizedDescription)")
                suggestions = []
                return
            }
            
            guard let response = response else {
                suggestions = []
                return
            }
            
            suggestions = response.mapItems
            
            // If fewer than 5 results, pad the list with empty results to ensure there are always more than 5
            if suggestions.count < 5 {
                let emptyItem = MKMapItem()
                suggestions.append(contentsOf: Array(repeating: emptyItem, count: 5 - suggestions.count))
            }
        }
    }
}

struct AddStopView_Previews: PreviewProvider {
    static var previews: some View {
        AddStopView(stops: .constant([]), isPresented: .constant(true))
    }
}
