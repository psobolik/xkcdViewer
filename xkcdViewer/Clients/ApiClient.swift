//
// Created by Paul Sobolik on 2019-07-20.
// Copyright (c) 2019 Paul Sobolik. All rights reserved.
//

import Foundation

class ApiClient : NSObject, URLSessionDataDelegate {
    typealias Handler = (Result<XkcdComic, Error>) -> Void

    private static let mimeType = "application/json"
    private var receivedData: Data?
    private var completionHandler: Handler?

    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private func getComicURL(comicNumber: UInt32?) -> URL {
        let folder = comicNumber != nil ? "\(comicNumber!)/" : ""
        let urlString = "https://xkcd.com/\(folder)info.0.json"
//        print("URL String: \(urlString)")
        return URL(string: urlString)!
    }

    public func getComicInfo(comicNumber: UInt32?, completionHandler: @escaping Handler) {
        self.completionHandler = completionHandler

        let url = getComicURL(comicNumber: comicNumber)
//        print("URL: \(url)")
        self.receivedData = Data()
        let task = urlSession.dataTask(with: url)
        task.resume()
    }

    // Delegate methods
    // Called when a response is received; We make sure the status code and mime type are right
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        print("Response \(response)")
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode),
              let mimeType = response.mimeType,
              mimeType == ApiClient.mimeType else {
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    // Called when data is received; We gather it in a data object
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        print("Data: \(data)")
        self.receivedData?.append(data)
    }

    // Called when the session completes, possibly due to an error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print("Complete!")
        DispatchQueue.main.async {
            if let error: Error = error {
                if self.completionHandler != nil {
                    self.completionHandler!(.failure(error))
                }
            } else if let receivedData = self.receivedData {//,
                      //let json = String(data: receivedData, encoding: .utf8) {
                if self.completionHandler != nil {
                    do {
                        let decoder = JSONDecoder()
                        let comic = try decoder.decode(XkcdComic.self, from: receivedData)
                        self.completionHandler!(.success(comic))
                    } catch {
                        // What to do?
                    }
                }
            }
        }
    }
}
