//
//  KeyboardObserver.swift
//  KeyboardObserver
//
//  Created by Keith Moon on 02/11/2015.
//  MIT Licence
//

import UIKit


public enum AppearanceEventLifecycle {
    
    case Will
    case Did
}


public enum KeyboardAppearanceEvent {
    
    case Show(AppearanceEventLifecycle)
    case Hide(AppearanceEventLifecycle)
    case Change(AppearanceEventLifecycle)
}


/**
 *  Metrics for the keyboard built from the Kayboard appearance notifications UserInfo dictionary
 */
public struct KeyboardMetrics {
    
    let beginFrame: CGRect
    let endFrame: CGRect
    let animationDuration: NSTimeInterval
    let animationCurve: UIViewAnimationCurve
    let animationOptionCurve: UIViewAnimationOptions
    
    init(beginFrame: CGRect, endFrame: CGRect, animationDuration: NSTimeInterval, animationCurve: UIViewAnimationCurve) {
        
        self.beginFrame = beginFrame
        self.endFrame = endFrame
        self.animationDuration = animationDuration
        self.animationCurve = animationCurve
        
        // The UIViewAnimationCurve value from the Keyboard Notification UserInfo is an undocumented value (Grrrr Apple!)
        // Bit shifting to the UIViewAnimationOptions enum is an unfortunately, but necessary, solution.
        animationOptionCurve = UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
    }
    
    
    init?(userInfo: [NSObject: AnyObject]) {
        
        if  let beginFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue,
            let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let animationDurationNumber = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let animationCurveNumber = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                let beginFrame = beginFrameValue.CGRectValue()
                let endFrame = endFrameValue.CGRectValue()
                let animationDuration = NSTimeInterval(animationDurationNumber.doubleValue)
                let animationCurve = UIViewAnimationCurve(rawValue: animationCurveNumber.integerValue)!
                
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
    weak var delegate: KeyboardObserverDelegate?
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        isObserving = true
    }
    
    
    /**
     Stop observing keyboard events
     */
    private func stopObservingKeyboard() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        isObserving = false
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Show(.Will), withMetrics: metrics)
        }
    }
    
    
    func keyboardDidShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Show(.Did), withMetrics: metrics)
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Hide(.Will), withMetrics: metrics)
        }
    }
    
    
    func keyboardDidHide(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Hide(.Did), withMetrics: metrics)
        }
    }
    
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Change(.Will), withMetrics: metrics)
        }
    }
    
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        
        if let userInfo = notification.userInfo, let metrics = KeyboardMetrics(userInfo: userInfo) {
            delegate?.keyboardObserver(self, hasReceivedEvent: .Change(.Did), withMetrics: metrics)
        }
    }
    
}


// MARK: - KeyboardObserverDelegate

protocol KeyboardObserverDelegate: class {
    
    /**
     Keyboard will show
     
     - parameter keyboardObserver:  KeyboardObserver
     - parameter hasReceivedEvent:  Event that was observed
     - parameter keyboardMetrics:   Keyboard Metrics struct
     */
    func keyboardObserver(keyboardObserver: KeyboardObserver, hasReceivedEvent event: KeyboardAppearanceEvent, withMetrics keyboardMetrics: KeyboardMetrics)
    
}
