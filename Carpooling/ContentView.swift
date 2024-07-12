import SwiftUI
import MapKit

struct ContentView: View {
    @State private var stops: [Stop] = [
        Stop(name: "My Location", icon: "location.fill", color: .blue),
        Stop(name: "Panera Bread", icon: "cup.and.saucer.fill", color: .orange)
    ]
    @State private var showingAddStopView = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map {
                UserAnnotation()
            }
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
        .edgesIgnoringSafeArea(.all) // Make sure edges are ignored for safe area
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
