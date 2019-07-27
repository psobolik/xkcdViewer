//
//  ViewController.swift
//  xkcdViewer
//
//  Created by Paul Sobolik on 2019-07-20.
//  Copyright © 2019 Paul Sobolik. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    private let apiClient = ApiClient()

    private var lastComicNumber: UInt32 = 0
    private var currentComicNumber: UInt32 = 0

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchComic(num: nil)
    }

    @IBAction func showFirstComic(_ sender: Any) {
        if self.currentComicNumber != 1 {
            self.fetchComic(num: 1)
        }
    }

    @IBAction func showPreviousComic(_ sender: Any) {
        if (currentComicNumber > 1) {
            fetchComic(num: currentComicNumber - 1)
        }
    }

    @IBAction func showLastComic(_ sender: Any) {
        if (currentComicNumber < lastComicNumber) {
            fetchComic(num: nil)
        }
    }

    @IBAction func showNextComic(_ sender: Any) {
        if (currentComicNumber < lastComicNumber) {
            fetchComic(num: currentComicNumber + 1)
        }
    }

    @IBAction func showRandomComic(_ sender: Any) {
        if lastComicNumber > 0 {
            fetchComic(num: UInt32.random(in: 1..<lastComicNumber))
        }
    }

    func fetchComic(num: UInt32?) {
        apiClient.getComicInfo(comicNumber: num, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                self!.showError(messageText: error.localizedDescription)
            case .success(let comic):
                if comic.num > 0 {
                    self!.currentComicNumber = comic.num
                    if (num == nil) {
                        self!.lastComicNumber = comic.num
                    }
                }
                self!.showComic(comic: comic)
                if comic.error != nil {
                    self!.showError(messageText: comic.error!)
                }
            }
        })
    }

    private func showComic(comic: XkcdComic) {
        titleLabel.stringValue = comic.title
        subtitleLabel.stringValue = comic.subtitle
        let url = URL(string: comic.img)
        imageView.image = url == nil ? nil : NSImage(contentsOf: URL(string: comic.img)!)
        imageView.toolTip = comic.alt
    }

    private func showError(messageText: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = messageText;
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: view.window!)
    }
}
