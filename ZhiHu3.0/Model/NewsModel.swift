//
//  model.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/5.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


// MARK: - LatestNews
struct LatestNews: Codable {
    let date: String
    var stories, topStories: [Story]

    enum CodingKeys: String, CodingKey {
        case date, stories
        case topStories = "top_stories"
    }
}

// MARK: LatestNews convenience initializers and mutators

extension LatestNews {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LatestNews.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        date: String? = nil,
        stories: [Story]? = nil,
        topStories: [Story]? = nil
    ) -> LatestNews {
        return LatestNews(
            date: date ?? self.date,
            stories: stories ?? self.stories,
            topStories: topStories ?? self.topStories
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}



// MARK: - Story
struct Story: Codable {
    let imageHue, title: String
    let url: String
    let hint, gaPrefix: String
    let images: [String]?
    let type, id: Int
    let image: String?

    enum CodingKeys: String, CodingKey {
        case imageHue = "image_hue"
        case title, url, hint
        case gaPrefix = "ga_prefix"
        case images, type, id, image
    }
}

// MARK: Story convenience initializers and mutators

extension Story {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Story.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        imageHue: String? = nil,
        title: String? = nil,
        url: String? = nil,
        hint: String? = nil,
        gaPrefix: String? = nil,
        images: [String]?? = nil,
        type: Int? = nil,
        id: Int? = nil,
        image: String?? = nil
    ) -> Story {
        return Story(
            imageHue: imageHue ?? self.imageHue,
            title: title ?? self.title,
            url: url ?? self.url,
            hint: hint ?? self.hint,
            gaPrefix: gaPrefix ?? self.gaPrefix,
            images: images ?? self.images,
            type: type ?? self.type,
            id: id ?? self.id,
            image: image ?? self.image
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }

            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }

            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }

    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }

    @discardableResult
    func responseLatestNews(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<LatestNews>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

//MARK: - DataRequest
struct newsHelper {
    static func dataManager(url: String, success: @escaping (([String: Any?]) -> ()),failure: ((Error) -> ())? = nil ){
        Alamofire.request(url).responseJSON{ response in
            switch response.result{
            case .success:
                if let data = response.result.value {
                    if let dic = data as? [String: Any] {
                        success(dic)
                    }
                }
            case .failure(let error):
                failure?(error)
                if let data = response.result.value {
                    if let dic = data as? [String: Any], let errorMessage = dic["message"] as? String{
                        print(errorMessage)
                    } else {
                        print(error)
                    }
                }
            }

        }
    }
}


struct latestNewsHelper {
    static func getLatestNews(success: @escaping (LatestNews) -> (), failure: @escaping (Error) -> ()){
        newsHelper.dataManager(url: "https://news-at.zhihu.com/api/4/news/latest", success: {dic in
            
            if let data = try?JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let latestnews = try? LatestNews(data: data) {
                success(latestnews)
              
            }
        }, failure:{ error in
            failure(error)
        })
        
    }
}


extension UIImageView {
    func setImageUrl(string: String?) {
        if(string != nil) {
           let url = URL(string: string!)!
            self.af_setImage(withURL: url)
        }
    }
}

