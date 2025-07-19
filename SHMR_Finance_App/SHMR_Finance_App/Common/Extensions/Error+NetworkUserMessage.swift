import Foundation

enum NetworkError: Error {
    case badResponse(Int)
    case invalidURL
    case networkError
    case decodingError
    case noInternetConnection
    case serverError(Int)
    case unauthorized
    case forbidden
    case notFound
    case tooManyRequests
    case internalServerError
    
    var userFriendlyMessage: String {
        switch self {
        case .badResponse(let code):
            return "Ошибка сервера (\(code)). Попробуйте позже."
        case .invalidURL:
            return "Некорректный адрес сервера."
        case .networkError:
            return "Ошибка сети. Проверьте соединение."
        case .decodingError:
            return "Ошибка обработки данных с сервера."
        case .noInternetConnection:
            return "Нет соединения с интернетом. Проверьте подключение."
        case .serverError(let code):
            return "Ошибка сервера (\(code)). Попробуйте позже."
        case .unauthorized:
            return "Необходима авторизация. Войдите в систему."
        case .forbidden:
            return "Доступ запрещен."
        case .notFound:
            return "Запрашиваемые данные не найдены."
        case .tooManyRequests:
            return "Слишком много запросов. Попробуйте позже."
        case .internalServerError:
            return "Внутренняя ошибка сервера. Попробуйте позже."
        }
    }
}

extension Error {
    var userFriendlyNetworkMessage: String {
        if let networkError = self as? NetworkError {
            return networkError.userFriendlyMessage
        }
        
        return "Произошла ошибка. Попробуйте позже."
    }
} 
