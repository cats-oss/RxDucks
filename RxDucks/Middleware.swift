//
//  Middleware.swift
//  RxDucks
//
//  Created by Kyohei Ito on 2018/07/13.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import RxSwift

public protocol MiddlewareType {
    /// the function does not have to override. Please use the function of the store that the middleware has, with the state specified.
    func on(_ store: StoreType, action: Action, next: @escaping (Action) -> Void) -> Disposable
}

public protocol Middleware: MiddlewareType {
    associatedtype State: StateType

    /// execute next action according to the input action.
    func on(_ store: Store<State>, action: Action, next: @escaping (Action) -> Void) -> Disposable
}

extension Middleware {
    public func on(_ store: StoreType, action: Action, next: @escaping (Action) -> Void) -> Disposable {
        if let store = store as? Store<State> {
            return on(store, action: action, next: next)
        }
        next(action)
        return Disposables.create()
    }
}
