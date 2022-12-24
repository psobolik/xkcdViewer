//
//  ComicClient.swift
//  xkcd Viewer
//
//  Created by Paul Sobolik on 2022-12-24.
//  Copyright © 2022 Paul Sobolik. All rights reserved.
//

import Foundation
import Cocoa

class ComicClient : NSObject, URLSessionDataDelegate {
    typealias Handler = (Result<NSImage, Error>) -> Void
    
    private static let mimeType = "image/png"
    private var receivedData: Data?
    private var completionHandler: Handler?

    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    public func getComicImage(url: URL, completionHandler: @escaping Handler) {
        self.completionHandler = completionHandler
        self.receivedData = Data()
        let task = urlSession.dataTask(with: url)
        task.resume()
    }
    
    // Delegate methods
    // Called when a response is received; We make sure the status code and mime type are right
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode),
              let mimeType = response.mimeType,
              mimeType == ComicClient.mimeType else {
            self.urlSession(session, task: dataTask, didCompleteWithError: InvalidResponseError(message: "Couldn't get comic image"))
            return
        }
        completionHandler(.allow)
    }

    // Called when data is received; We gather it in a data object
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receivedData?.append(data)
    }

    // Called when the session completes, possibly due to an error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let completionHandler = self.completionHandler {
            if let error: Error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(error))
                    
                }
            }
            else if let receivedData = self.receivedData {
                if let image = NSImage(data: receivedData) {
                    DispatchQueue.main.async {
                        completionHandler(.success(image))
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failure(InvalidResponseError(message: "Error getting comic image")))
                    }
                }
            }
        }
    }
}


