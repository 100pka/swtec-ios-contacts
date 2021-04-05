//
//  Async.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/31/21.
//

import Foundation

public func asyncMain(execute work: @escaping () -> Void) {
    DispatchQueue.main.async(execute: work)
}

public func async(execute work: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: work)
}
