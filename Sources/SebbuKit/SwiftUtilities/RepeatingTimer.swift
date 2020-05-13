//
//  RepeatingTimer.swift
//  
//
//  Created by Sebastian Toivonen on 12.5.2020.
//

import Foundation
import Dispatch

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
public class RepeatingTimer {

    public let timeInterval: DispatchTimeInterval
    private let queue: DispatchQueue?
    
    init(timeInterval:  DispatchTimeInterval, queue: DispatchQueue? = nil) {
        self.timeInterval = timeInterval
        self.queue = queue
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    public var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
