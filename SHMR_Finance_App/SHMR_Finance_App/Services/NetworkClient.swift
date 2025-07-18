//
//  NetworkClient.swift
//  SHMR_Finance_App55

import Foundation

final class NetworkClient {
    
    let urlString = "https://shmr-finance.ru/"
    private let token = "NC6Lmc6wwJ02KQ06urPOj4gm"
    
    static let shared = NetworkClient()
    
    private init() { }

    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ"
            ]

            for format in formats {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date string '\(dateString)' does not match any expected format"
            )
        }
        return decoder
    }()
    
    func request(endpointValue: String) async throws -> Data {
        let endpoint = urlString + endpointValue
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try Task.checkCancellation()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError
            }
            
            guard validStatus.contains(httpResponse.statusCode) else {
                throw handleHTTPError(statusCode: httpResponse.statusCode)
            }
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError
        }
    }
    
    // получение и декодирование данных
    func fetchDecodeData<T: Codable>(endpointValue: String, dataType: T.Type) async throws -> [T] {
        do {
            let data = try await self.request(endpointValue: endpointValue)
            return try decoder.decode([T].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    @discardableResult
    func request(endpointValue: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        let endpoint = urlString + endpointValue
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }
        try Task.checkCancellation()
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError
            }
            
            guard validStatus.contains(httpResponse.statusCode) else {
                throw handleHTTPError(statusCode: httpResponse.statusCode)
            }
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError
        }
    }
}

let validStatus = 200...299

protocol HTTPDataDownloader: Sendable {
    func httpData(from url: URL) async throws -> Data
}

extension URLSession: HTTPDataDownloader {
    func httpData(from url: URL) async throws -> Data {
        guard let (data, response) = try await self.data(from: url, delegate: nil) as? (Data, HTTPURLResponse),
              validStatus.contains(response.statusCode) else {
            throw NetworkError.networkError
        }
        return data
    }
}

extension NetworkClient {
    private func handleHTTPError(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400:
            return .badResponse(statusCode)
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .tooManyRequests
        case 500...599:
            return .internalServerError
        default:
            return .serverError(statusCode)
        }
    }
}

//enum NetworkError: Error {
//    case badResponse(Int)
//    case invalidURL
//    case networkError
//    case decodingError
//    case noInternetConnection
//    case serverError(Int)
//    case unauthorized
//    case forbidden
//    case notFound
//    case tooManyRequests
//    case internalServerError
//    
//    var userFriendlyMessage: String {
//        switch self {
//        case .badResponse(let code):
//            return "Ошибка сервера (\(code)). Попробуйте позже."
//        case .invalidURL:
//            return "Некорректный адрес сервера."
//        case .networkError:
//            return "Ошибка сети. Проверьте соединение."
//        case .decodingError:
//            return "Ошибка обработки данных с сервера."
//        case .noInternetConnection:
//            return "Нет соединения с интернетом. Проверьте подключение."
//        case .serverError(let code):
//            return "Ошибка сервера (\(code)). Попробуйте позже."
//        case .unauthorized:
//            return "Необходима авторизация. Войдите в систему."
//        case .forbidden:
//            return "Доступ запрещен."
//        case .notFound:
//            return "Запрашиваемые данные не найдены."
//        case .tooManyRequests:
//            return "Слишком много запросов. Попробуйте позже."
//        case .internalServerError:
//            return "Внутренняя ошибка сервера. Попробуйте позже."
//        }
//    }
//}

extension DateFormatter {
    static let withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
