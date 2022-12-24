//
//  InvalidResponseError.swift
//  xkcd Viewer
//
//  Created by Paul Sobolik on 12/24/22.
//  Copyright © 2022 Paul Sobolik. All rights reserved.
//

import Foundation

class InvalidResponseError: Error {
    var message: String
    init(message: String) {
        self.message = message
    }
}
