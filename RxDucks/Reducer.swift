//
//  Reducer.swift
//  SuperChoice
//
//  Created by Kyohei Ito on 2017/10/20.
//  Copyright © 2017年 CyberAgent, Inc. All rights reserved.
//

import RxSwift

public protocol Reducer {
    associatedtype State: StateType

    /// mutates an input state to an output state according to the action.
    func reduce(_ state: State, action: Action) -> State
}
