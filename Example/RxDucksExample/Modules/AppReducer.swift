//
//  AppReducer.swift
//  RxDucksExample
//
//  Created by Kyohei Ito on 2018/07/20.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import RxDucks

struct AppState: State {
    var user = UserState()
    var load = LoadState()
}

struct AppReducer: Reducer {
    func reduce(_ state: AppState, action: Action) -> AppState {
        return AppState(user: UserReduder.reduce(state.user, action: action),
                        load: LoadReducer.reduce(state.load, action: action))
    }
}
