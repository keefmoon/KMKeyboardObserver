//
//  ViewController.swift
//  Example
//
//  Created by Keith Moon on 04/01/2018.
//  Copyright © 2018 Data Ninjitsu. All rights reserved.
//

import UIKit
import KeyboardObserver

class ViewController: UIViewController {

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    var keyboardObserver = KeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardObserver.delegate = self
    }
}

extension ViewController: KeyboardObserverDelegate {
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, hasReceivedEvent event: KeyboardAppearanceEvent, withMetrics keyboardMetrics: KeyboardMetrics) {
        
        switch event {
            
        case .change(.will):
            
            let intersect = view.frame.intersection(keyboardMetrics.endFrame)
            bottomConstraint.constant = intersect.height
            
            UIView.animate(withDuration: keyboardMetrics.animationDuration, delay: 0.0, options: keyboardMetrics.animationOptionCurve, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        default:
            break
        }
    }
}
