//
//  Action.swift
//  RxDucks
//
//  Created by Kyohei Ito on 2017/10/20.
//  Copyright © 2017年 CyberAgent, Inc. All rights reserved.
//

public protocol Action {}
public protocol IgnorableAction: Action {}

public final class ActionCreator {
    public init() {}
}
