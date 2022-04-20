//
//  NetworkService.swift
//  CombineTwoRequest0420
//
//  Created by 张亚飞 on 2022/4/20.
//

import Foundation
import Combine
import Metal

enum NetworkError: Error, CustomStringConvertible {
    
    case URLError
    case DecodeError
    case ResponseError(error: Error)
    case unknown
    
    var description: String {
        
        switch self {
            
        case .URLError:
            return "无效的URL"
        case .ResponseError(let error):
            return "网络错误：\(error.localizedDescription)"
        case .DecodeError:
            return "解码错误"
        case .unknown:
            return "未知错误"
        }
    }
}



class NetworkService {
    
    static let shared = NetworkService()
    
    func fetchUser(index: String) -> AnyPublisher<UserModel, Error> {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/users/" + index)
        
        guard let url = url else {
            
            return Fail(error: NetworkError.URLError).eraseToAnyPublisher()
        }

        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    throw URLError(.badServerResponse)
                }
                
                return element.data
            }
            .decode(type: UserModel.self, decoder: JSONDecoder())
            .mapError{ error -> NetworkError in
                
                switch error {
                case is URLError:
                    return .ResponseError(error: error)
                case is DecodingError:
                    return .DecodeError
                default:
                    return error as? NetworkError ?? .unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchPost(index: String) -> AnyPublisher<PostMode, Error> {
        
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/" + index)
        
        guard let url = url else {
            
            return Fail(error: NetworkError.URLError).eraseToAnyPublisher()
        }

        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    
                    throw URLError(.badServerResponse)
                }
                
                return element.data
            }
            .decode(type: PostMode.self, decoder: JSONDecoder())
            .mapError{ error -> NetworkError in
                
                switch error {
                case is URLError:
                    return .ResponseError(error: error)
                case is DecodingError:
                    return .DecodeError
                default:
                    return error as? NetworkError ?? .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
