import Foundation
import CoreLocation
import SwiftUI

struct Stop: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var coordinate: CLLocationCoordinate2D
}
