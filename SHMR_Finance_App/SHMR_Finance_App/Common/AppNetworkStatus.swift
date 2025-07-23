import Foundation

final class AppNetworkStatus: ObservableObject {
    @Published var isOffline: Bool = false
    private var lastNetworkError: Date?
    private var successfulRequestsCount: Int = 0
    
    public init() {}
    
    func setOffline() {
        DispatchQueue.main.async {
            self.isOffline = true
            self.lastNetworkError = Date()
            self.successfulRequestsCount = 0
        }
    }
    
    func setOnline() {
        DispatchQueue.main.async {
            self.isOffline = false
            self.lastNetworkError = nil
        }
    }
    
    func handleNetworkError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .networkError, .noInternetConnection:
                setOffline()
            default:
                // другие ошибки - не переключаем в офлайн
                break
            }
        } else {
            // неизвестные ошибки - переключаем в офлайн
            setOffline()
        }
    }
    
    func handleSuccessfulRequest() {
        successfulRequestsCount += 1
        // несколько успешных запросов подряд, считаем что мы онлайн
        if successfulRequestsCount >= 2 {
            setOnline()
        }
    }
} 
