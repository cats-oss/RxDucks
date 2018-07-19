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

    func reduce(_ state: State, action: Action) -> State
}
