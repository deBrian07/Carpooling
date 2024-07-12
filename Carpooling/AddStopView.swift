import SwiftUI
import CoreLocation

struct AddStopView: View {
    @Binding var stops: [Stop]
    @Binding var isPresented: Bool
    @State private var newStopAddress: String = ""
    @State private var suggestions: [GooglePlace] = []
    
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
                    List(suggestions, id: \.place_id) { suggestion in
                        VStack(alignment: .leading) {
                            Text(suggestion.description)
                                .font(.headline)
                        }
                        .padding()
                        .onTapGesture {
                            fetchPlaceDetails(for: suggestion)
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
    
    private func addStop(name: String, coordinate: CLLocationCoordinate2D) {
        let newStop = Stop(name: name, icon: "mappin.and.ellipse", color: .red, coordinate: coordinate)
        stops.append(newStop)
        newStopAddress = ""
        suggestions.removeAll()
        isPresented = false // Ensure the view is dismissed after adding the stop
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
                    suggestions = result.predictions
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                suggestions = []
            }
        }.resume()
    }
    
    private func fetchPlaceDetails(for place: GooglePlace) {
        let apiKey = "AIzaSyDqUQ612HWNtf4_NKSlY_OHhuSaU4uOGGk"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(place.place_id)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                let coordinate = CLLocationCoordinate2D(latitude: result.result.geometry.location.lat, longitude: result.result.geometry.location.lng)
                DispatchQueue.main.async {
                    addStop(name: place.description, coordinate: coordinate)
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
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
    let predictions: [GooglePlace]
}

struct GooglePlace: Decodable {
    let description: String
    let place_id: String
}

struct PlaceDetailsResponse: Decodable {
    let result: PlaceDetails
}

struct PlaceDetails: Decodable {
    let geometry: Geometry
}

struct Geometry: Decodable {
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}
