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
        fetchComic(num: UInt32.random(in: 1 ..< lastComicNumber))
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func fetchComic(num: UInt32?) {
        apiClient.getComicInfo(comicNumber: num, completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                self!.showError(error: error)
            case .success(let comic):
                self!.currentComicNumber = comic.num
                if num == nil { self!.lastComicNumber = comic.num }
                self!.showComic(comic: comic)
            }
        })
    }

    private func showComic(comic: XkcdComic) {
        self.titleLabel.stringValue = comic.title
        self.subtitleLabel.stringValue = comic.subtitle
        self.imageView.image = NSImage(contentsOf: URL(string: comic.img)!)
        imageView.toolTip = comic.alt
    }
    
    private func showError(error: Error) {
        // TODO: Show Error
    }
}
