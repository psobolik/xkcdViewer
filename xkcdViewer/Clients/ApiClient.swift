//
// Created by Paul Sobolik on 2019-07-20.
// Copyright (c) 2019 Paul Sobolik. All rights reserved.
//

import Foundation

class ApiClient: NSObject, URLSessionDataDelegate {
    typealias Handler = (Result<XkcdComic, Error>) -> Void

    private static let mimeType = "application/json"
    private var receivedData: Data?
    private var completionHandler: Handler?

    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private func getComicInfoURL(comicNumber: UInt32?) -> URL {
        let folder = comicNumber != nil ? "\(comicNumber!)/" : ""
        let urlString = "https://xkcd.com/\(folder)info.0.json"
//        print("URL String: \(urlString)")
        return URL(string: urlString)!
    }

    public func getComicInfo(comicNumber: UInt32?, completionHandler: @escaping Handler) {
        self.completionHandler = completionHandler

        let url = getComicInfoURL(comicNumber: comicNumber)
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
            self.urlSession(session, task: dataTask, didCompleteWithError: InvalidResponseError(message: "Couldn't get comic info"))
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
        var comic: XkcdComic = XkcdComic()
        if let error: Error = error {
            if error is InvalidResponseError {
                comic.error = (error as! InvalidResponseError).message
            } else {
                comic.error = error.localizedDescription
            }
        } else if let receivedData = self.receivedData {
//                let dataString = String(data: receivedData, encoding: .utf8)
//                print(dataString!)
            do {
                let decoder = JSONDecoder()
                comic = try decoder.decode(XkcdComic.self, from: receivedData)
            } catch {
                // This should never happen
                comic.error = error.localizedDescription
            }
        }
        DispatchQueue.main.async {
            if self.completionHandler != nil {
                self.completionHandler!(.success(comic))
            }
        }
    }
}
