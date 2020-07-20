//
//  ImageCache.swift
//  chatUI
//
//  Created by Faris Albalawi on 7/19/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

typealias JSON = [String : Any]
fileprivate let imageCache = NSCache<NSString, UIImage>()

extension NSError {
    static func generalParsingError(domain: String) -> Error {
        return NSError(domain: domain, code: 400, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Error retrieving data", comment: "General Parsing Error Description")])
    }
}

class ImageCache {
    
    //MARK: - Public
    
    static func downloadImage(url: URL,completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completionHandler(.success(cachedImage))
        } else {
            ImageCache.downloadData(url: url) { data, response, error in
                if let error = error {
                    completionHandler(.failure(error))
                    
                } else if let data = data, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(NSError.generalParsingError(domain: url.absoluteString)))
                }
            }
        }
    }

    //MARK: - Private
    
    private static func downloadData(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession(configuration: .ephemeral).dataTask(with: URLRequest(url: url)) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    private static func convertToJSON(with data: Data) -> JSON? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON
        } catch {
            return nil
        }
    }
}


extension UIImageView {
    func setImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        ImageCache.downloadImage(url: url) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.image = image
                }

            case .failure:
                break
            }
        }
    }
}
