import Foundation

class AppNetworkStatus: ObservableObject {
    static let shared = AppNetworkStatus()
    @Published var isOffline: Bool = false
    private init() {}
} 