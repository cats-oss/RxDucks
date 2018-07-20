//
//  Action.swift
//  RxDucks
//
//  Created by Kyohei Ito on 2017/10/20.
//  Copyright © 2017年 CyberAgent, Inc. All rights reserved.
//

/// change of Action is notified to the state the store has.
public protocol Action {}

/// change of IgnorableAction is not notified to the state the store has.
public protocol IgnorableAction: Action {}

public final class ActionCreator {
    public init() {}
}
