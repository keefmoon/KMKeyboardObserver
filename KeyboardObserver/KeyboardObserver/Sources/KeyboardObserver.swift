//
//  KeyboardObserver.swift
//  KeyboardObserver
//
//  Created by Keith Moon on 02/11/2015.
//  MIT Licence
//

import UIKit

public enum AppearanceEventLifecycle {
    case will
    case did
}

public enum KeyboardAppearanceEvent {
    case show(AppearanceEventLifecycle)
    case hide(AppearanceEventLifecycle)
    case change(AppearanceEventLifecycle)
}

/**
 *  Metrics for the keyboard built from the Kayboard appearance notifications UserInfo dictionary
 */
public struct KeyboardMetrics {
    
    public let beginFrame: CGRect
    public let endFrame: CGRect
    public let animationDuration: TimeInterval
    public let animationCurve: UIView.AnimationCurve
    public let animationOptionCurve: UIView.AnimationOptions
    
    init(beginFrame: CGRect, endFrame: CGRect, animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve) {
        
        self.beginFrame = beginFrame
        self.endFrame = endFrame
        self.animationDuration = animationDuration
        self.animationCurve = animationCurve
        
        // The UIViewAnimationCurve value from the Keyboard Notification UserInfo is an undocumented value (Grrrr Apple!)
        // Bit shifting to the UIViewAnimationOptions enum is an unfortunately, but necessary, solution.
        animationOptionCurve = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
    }
    
    init?(userInfo: [AnyHashable: Any]) {
        
        if  let beginFrameValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
            let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationDurationNumber = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
            let animationCurveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                let beginFrame = beginFrameValue.cgRectValue
                let endFrame = endFrameValue.cgRectValue
                let animationDuration = TimeInterval(animationDurationNumber.doubleValue)
                let animationCurve = UIView.AnimationCurve(rawValue: animationCurveNumber.intValue)!
                
                self = KeyboardMetrics(beginFrame: beginFrame, endFrame: endFrame, animationDuration: animationDuration, animationCurve: animationCurve)
                
        } else {
            return nil
        }
    }
}

/*
 * More swifty wrapper around the Keyboard notifications
 *
 * Informs a delegate when the keyboard metrics change. 
 */
public class KeyboardObserver: NSObject {
    
    // Delegate to be notified
    public weak var delegate: KeyboardObserverDelegate?
    
    /// Indicates if the Keyboard observer is currently observing keyboard changes
    private var isObserving = false
    
    /**
     Start observing the keyboard as soon as it is initiated
     */
    public override init() {
        super.init()
        startObservingKeyboard()
    }
    
    deinit {
        if isObserving {
            stopObservingKeyboard()
        }
    }
    
    // MARK: - Keyboard Observing Methods
    
    /**
    Start observing keyboard events
    */
    private func startObservingKeyboard() {
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        isObserving = true
    }
    
    /**
     Stop observing keyboard events
     */
    private func stopObservingKeyboard() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        isObserving = false
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .show(.will), withMetrics: metrics)
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .show(.did), withMetrics: metrics)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .hide(.will), withMetrics: metrics)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .hide(.did), withMetrics: metrics)
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .change(.will), withMetrics: metrics)
        }
    }
    
    @objc func keyboardDidChangeFrame(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .change(.did), withMetrics: metrics)
        }
    }
}

// MARK: - KeyboardObserverDelegate

public protocol KeyboardObserverDelegate: class {
    
    /**
     Keyboard will show
     
     - parameter keyboardObserver:  KeyboardObserver
     - parameter hasReceivedEvent:  Event that was observed
     - parameter keyboardMetrics:   Keyboard Metrics struct
     */
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, hasReceivedEvent event: KeyboardAppearanceEvent, withMetrics keyboardMetrics: KeyboardMetrics)
}
