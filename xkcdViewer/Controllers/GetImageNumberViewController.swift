//
//  GetImageNumberViewController.swift
//  xkcd Viewer
//
//  Created by Paul Sobolik on 7/27/19.
//  Copyright © 2019 Paul Sobolik. All rights reserved.
//

import Cocoa

class GetImageNumberViewController : NSViewController {
    private var _selectedComicNumber: UInt32 = 0

    var selectedComicNumber: UInt32 {
        set {
            _selectedComicNumber = newValue
            comicNumberTextField.intValue = Int32(newValue)
            comicNumberStepper.intValue = Int32(newValue)        }
        get {
            return _selectedComicNumber
        }
    }
    
    var lastComicNumber : UInt32 {
        set {
            comicNumberStepper.maxValue = Double(newValue)
            let f = comicNumberTextField.formatter as? NumberFormatter
            f?.maximum = NSNumber(value: newValue)
        }
        get {
            return UInt32(comicNumberStepper.maxValue)
        }
    }

    @IBOutlet weak var comicNumberTextField: NSTextField!
    @IBOutlet weak var comicNumberStepper: NSStepper!

    @IBAction func onComicNumberChanged(_ sender: Any) {
        guard let textField = sender as? NSTextField else { return }
        selectedComicNumber = UInt32(textField.intValue)
    }
    
    @IBAction func onComicNumberStep(_ sender: Any) {
        guard let stepper = sender as? NSStepper else { return }
        selectedComicNumber = UInt32(stepper.intValue)
    }
    
    @IBAction func showComicNumber(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .OK)
    }
    
    @IBAction func cancel(_ sender: Any) {
        guard let window = self.view.window, let parent = window.sheetParent else { return }
        parent.endSheet(window, returnCode: .cancel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
