import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var stops: [Stop] = [
        Stop(name: "My Location", icon: "location.fill", color: .blue, coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
    ]
    @State private var showingAddStopView = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))), annotationItems: stops) { stop in
                MapAnnotation(coordinate: stop.coordinate) {
                    VStack {
                        Image(systemName: stop.icon)
                            .foregroundColor(stop.color)
                            .background(Circle().fill(Color.white))
                        Text(stop.name.components(separatedBy: ",").first ?? stop.name)
                            .font(.caption)
                            .background(Color.white)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                VStack {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .padding()
            }
            
            VStack(spacing: 0) {
                Spacer()
                StopListView(stops: $stops, showingAddStopView: $showingAddStopView)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingAddStopView) {
            AddStopView(stops: $stops, isPresented: $showingAddStopView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
