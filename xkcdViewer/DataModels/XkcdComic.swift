//
// Created by Paul Sobolik on 2019-07-21.
// Copyright (c) 2019 Paul Sobolik. All rights reserved.
//

import Foundation

class XkcdComic : Codable {
    var num: UInt32
    var year: String
    var month: String
    var day: String
    var title: String
    var safe_title: String
    var alt: String
    var img: String
    var link: String
    var news: String
    var transcript: String
    var error: String?

    var date: Date {
        get {
            var dateComponents = DateComponents()
            dateComponents.day = Int(self.day)
            dateComponents.month = Int(self.month)
            dateComponents.year = Int(self.year)
            let calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            return calendar.date(from: dateComponents)!
        }
    }

    var dateString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: self.date)
        }
    }
    var subtitle: String {
        get {
            return num > 0 && dateString != nil
                    ? "#\(self.num) \(self.dateString)"
                    : ""
        }
    }
    init() {
        self.num = 0
        self.year = String()
        self.month = String()
        self.day = String()
        self.title = String()
        self.safe_title = String()
        self.alt = String()
        self.img = String()
        self.link = String()
        self.news = String()
        self.transcript = String()
    }
}

extension String {
    init(comic: XkcdComic) {
        self.init("XkcdComic: { num: \(comic.num), year: \"\(comic.year)\", month: \"\(comic.month)\", day: \"\(comic.day)\", title: \"\(comic.title)\", safe_title: \"\(comic.safe_title)\", alt: \"\(comic.alt)\", img: \"\(comic.img)\", link: \"\(comic.link)\", news: \"\(comic.news)\", transcript: \"\(comic.transcript)\" }")
    }
}
/*
Example:
{
    "month": "5",
    "num": 100,
    "link": "",
    "year": "2006",
    "news": "",
    "safe_title": "Family Circus",
    "transcript": "[[Picture shows a pathway winding through trees to a sink inside a house, out to some swings and back to ths sink, out to a ball and back to the sink...]]\nCaption: Jeffy's ongoing struggle with obsessive-compulsive disorder\n{{alt text: This was my friend David's idea}}",
    "alt": "This was my friend David's idea",
    "img": "https://imgs.xkcd.com/comics/family_circus.jpg",
    "title": "Family Circus",
    "day": "10"
}
*/