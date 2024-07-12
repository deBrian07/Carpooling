import SwiftUI

struct AddStopView: View {
    @Binding var stops: [Stop]
    @Binding var isPresented: Bool
    @State private var newStopAddress: String = ""
    @State private var suggestions: [String] = []
    
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
                        Text(suggestion)
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
    
    private func addStop(_ address: String) {
        let newStop = Stop(name: address, icon: "mappin.and.ellipse", color: .red)
        stops.append(newStop)
        newStopAddress = ""
        suggestions.removeAll()
    }
    
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        let apiKey = "AIzaSyDqUQ612HWNtf4_NKSlY_OHhuSaU4uOGGk"
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(query)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            suggestions = []
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching suggestions: \(error.localizedDescription)")
                suggestions = []
                return
            }
            
            guard let data = data else {
                print("No data received")
                suggestions = []
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)
                DispatchQueue.main.async {
                    suggestions = result.predictions.map { $0.description }
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                suggestions = []
            }
        }.resume()
    }
}

struct AddStopView_Previews: PreviewProvider {
    static var previews: some View {
        AddStopView(stops: .constant([]), isPresented: .constant(true))
    }
}

struct PlacesAutocompleteResponse: Decodable {
    let predictions: [Prediction]
}

struct Prediction: Decodable {
    let description: String
}
