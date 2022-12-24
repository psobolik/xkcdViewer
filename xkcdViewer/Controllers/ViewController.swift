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
    private let comicClient = ComicClient()
    
    private var lastComicNumber: UInt32 = 0
    private var currentComicNumber: UInt32 = 0

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var firstButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var randomButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var lastButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchComic(num: nil)
    }

    @IBAction func showComicByNumber(_ sender: Any) {
        let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: "ShowComicNumber")
        guard let windowController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSWindowController,
              let window = windowController.window,
              let viewController = windowController.contentViewController as? GetImageNumberViewController
                else { return }
        viewController.lastComicNumber = lastComicNumber
        viewController.selectedComicNumber = currentComicNumber

        self.view.window?.beginSheet(window, completionHandler: { (response) in
            if response == NSApplication.ModalResponse.OK {
                let newComicNum = viewController.selectedComicNumber
                if self.currentComicNumber != newComicNum {
                    self.fetchComic(num: newComicNum)
                }
            }
        })
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

    private func adjustButtons() {
        let notAtFirst = currentComicNumber > 1
        let notAtLast = currentComicNumber < lastComicNumber

        firstButton.isEnabled = notAtFirst
        previousButton.isEnabled = notAtFirst
        randomButton.isEnabled = lastComicNumber > 0
        nextButton.isEnabled = notAtLast
        lastButton.isEnabled = notAtLast
    }

    private func showComic(comic: XkcdComic) {
        if let url = URL(string: comic.img) {
            comicClient.getComicImage(url: url, completionHandler: { [weak self] result in
                switch result {
                case .failure(let error):
                    self!.showError(messageText: error.localizedDescription)
                case .success(let image):
                    self!.imageView.image = image
                    self!.titleLabel.stringValue = comic.title
                    self!.subtitleLabel.stringValue = comic.subtitle
                    self!.imageView.toolTip = comic.alt
                }
            })
        }
    }

    private func showError(messageText: String) {
        let alert: NSAlert = NSAlert()
        alert.messageText = messageText;
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: view.window!)
    }
}
