//
//  WebService.swift
//  RapsodoAssignment
//
//  Created by Arda Yatman on 3.02.2022.
//

import Foundation


enum NetworkError:Error {
    case apiError
    case decodingError
}

struct Resource<T:Codable>{
    let url:URL
}

class WebService {
    
    static func fetchData<T>(resource: Resource<T>, completion: @escaping(Result<T,NetworkError>) -> Void) {
        
        //TODO: Activity Indicator ekle
        
        URLSession.shared.dataTask(with: resource.url) { data,response,error in
            
            guard let data = data, error == nil else {
                completion(.failure(.apiError))
                return
            }
            
            //print("Response \( NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!))")
            
            let result = try? JSONDecoder().decode(T.self, from: data)
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            }else {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
}
