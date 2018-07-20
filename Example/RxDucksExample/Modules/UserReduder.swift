//
//  UserReduder.swift
//  RxDucksExample
//
//  Created by Kyohei Ito on 2018/07/20.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import RxDucks

struct LogInAction: Action {}
struct LogOutAction: Action {}

extension ActionCreator {
    static func logIn() -> LogInAction {
        return LogInAction()
    }

    static func logOut() -> LogOutAction {
        return LogOutAction()
    }
}

struct UserState: State {
    var loggedIn = false
}

struct UserReduder {
    static func reduce(_ state: UserState, action: Action) -> UserState {
        switch action {
        case is LogOutAction:
            return UserState(loggedIn: false)
        default:
            break
        }

        switch action as? LoadAction {
        case .loaded?:
            return UserState(loggedIn: true)
        default:
            break
        }

        return state
    }
}
