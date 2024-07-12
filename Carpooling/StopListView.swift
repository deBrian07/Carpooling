import SwiftUI

struct StopListView: View {
    @Binding var stops: [Stop]
    @Binding var showingAddStopView: Bool
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            List {
                ForEach(stops) { stop in
                    HStack {
                        Image(systemName: stop.icon)
                            .foregroundColor(stop.color)
                        Text(stop.name)
                        Spacer()
                        Menu {
                            if stop.name != "My Location" {
                                Button(action: {
                                    removeStop(stop: stop)
                                }) {
                                    Text("Remove")
                                    Image(systemName: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Button(action: {
                    showingAddStopView = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add Stop")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(height: UIScreen.main.bounds.height / 3)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .padding(.bottom, 0) // Ensure bottom padding is zero
    }
    
    private func removeStop(stop: Stop) {
        if stop.name != "My Location", let index = stops.firstIndex(where: { $0.id == stop.id }) {
            stops.remove(at: index)
        }
    }
}

struct StopListView_Previews: PreviewProvider {
    static var previews: some View {
        StopListView(stops: .constant([
            Stop(name: "My Location", icon: "location.fill", color: .blue),
            Stop(name: "Panera Bread", icon: "cup.and.saucer.fill", color: .orange)
        ]),
        showingAddStopView: .constant(false))
    }
}
