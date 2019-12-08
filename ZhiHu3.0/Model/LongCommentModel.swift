//
//  LongCommentModel.swift
//  ZhiHu3.0
//
//  Created by 游奕桁 on 2019/12/8.
//  Copyright © 2019 游奕桁. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - LongComment
struct LongComment: Codable {
    let comments: [Comment]
}

// MARK: LongComment convenience initializers and mutators

extension LongComment {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LongComment.self, from: data)
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
        comments: [Comment]? = nil
    ) -> LongComment {
        return LongComment(
            comments: comments ?? self.comments
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseComment { response in
//     if let comment = response.result.value {
//       ...
//     }
//   }

// MARK: - Comment
struct Comment: Codable {
    let author, content: String
    let avatar: String
    let time, id, likes: Int
}

// MARK: Comment convenience initializers and mutators

extension Comment {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Comment.self, from: data)
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
        author: String? = nil,
        content: String? = nil,
        avatar: String? = nil,
        time: Int? = nil,
        id: Int? = nil,
        likes: Int? = nil
    ) -> Comment {
        return Comment(
            author: author ?? self.author,
            content: content ?? self.content,
            avatar: avatar ?? self.avatar,
            time: time ?? self.time,
            id: id ?? self.id,
            likes: likes ?? self.likes
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

func newJSONDecoder2() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder2() -> JSONEncoder {
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
    func responseLongComment(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<LongComment>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

struct CommentRequest {
    
    static func getComment(success: @escaping(LongComment) -> (), failure: @escaping (Error) -> ()) {
//        let url = ViewController.news.stories[ViewController.row].url+"/long-comments"
        let url = "https://news-at.zhihu.com/api/4/story/" + String(ViewController.news.stories[ViewController.row].id) + "/comments"
        newsHelper.dataManager(url: url, success: {dic in
            if let data = try?JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let longComment = try? LongComment(data: data) {
                success(longComment)
            }
        }, failure: { error in
            failure(error)
            print(error)
        })
    }

    
}
