//
//  Store.swift
//  SuperChoice
//
//  Created by Kyohei Ito on 2017/10/20.
//  Copyright © 2017年 CyberAgent, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol StoreType {}

open class Store<State: StateType>: StoreType {
    private let disposeBag = DisposeBag()
    private let _state: BehaviorRelay<State>
    private let _action = PublishRelay<Action>()
    private let _dispatcher = PublishRelay<Action>()
    private var _newState: Observable<State> {
        return _state.skip(1)
    }

    /// the current state the store has
    public var currentState: State {
        return _state.value
    }

    /// Observable that sends changed elements and current element.
    /// IgnorableAction changes are not notified.
    /// it doesn't terminate with error or completed.
    public var state: Observable<State> {
        return newState
            .startWith(_state.value)
    }

    /// Observable that only sends changed elements, ignoring current element.
    /// IgnorableAction changes are not notified.
    /// it doesn't terminate with error or completed.
    public var newState: Observable<State> {
        return Observable.zip(_action, _newState)
            .flatMap { action, state -> Observable<State> in
                if action is IgnorableAction {
                    return .empty()
                }
                return .just(state)
            }
    }

    /// Binder that dispatch an action.
    public var dispatcher: Binder<Action> {
        return Binder(self, scheduler: CurrentThreadScheduler.instance) { me, type in
            me.dispatch(type)
        }
    }

    /// Dispatch an action through the middlewares and the reducers to mutate the state.
    /// - Parameter action: the action that will be through the middlewares and the reducers.
    public func dispatch(_ action: Action) {
        _dispatcher.accept(action)
    }

    /// initialize the Store.
    /// - Parameter reducer: the reducer to be executed by the dispatcher.
    /// - Parameter state: the initial state.
    /// - Parameter middlewares: the middlewares of Variadic Parameters to be executed by the dispatcher.
    public convenience init<R: Reducer>(reducer: R, state: State, middlewares: MiddlewareType...) where R.State == State {
        self.init(reducer: reducer, state: state, middlewares: middlewares as [MiddlewareType])
    }

    /// initialize the Store.
    /// - Parameter reducer: the reducer to be executed by the dispatcher.
    /// - Parameter state: the initial state.
    /// - Parameter middlewares: the middlewares of Array to be executed by the dispatcher.
    public init<R: Reducer>(reducer: R, state: State, middlewares: [MiddlewareType]) where R.State == State {
        _state = BehaviorRelay<State>(value: state)

        let actionState: Observable<(Action, State)> = _dispatcher
            .flatMap { [weak self] action -> Observable<Action> in
                guard let me = self else { return .empty() }

                return middlewares.reduce(.just(action)) { observable, middleware in
                    observable.flatMap { action in
                        return Observable.create { observer in
                            return middleware.on(me, action: action) { action in
                                observer.onNext(action)
                                observer.onCompleted()
                            }
                        }
                    }
                }
            }
            .withLatestFrom(_state) { action, state in
                (action, reducer.reduce(state, action: action))
            }
            .share()

        actionState
            .map { $0.0 }
            .bind(to: _action)
            .disposed(by: disposeBag)

        actionState
            .map { $0.1 }
            .bind(to: _state)
            .disposed(by: disposeBag)
    }
}

extension Store {
    /// Specific element avoiding duplicate notifications.
    /// IgnorableAction changes are not notified.
    /// - Parameter selector: the closure that allows to extract an Element
    /// - Returns: an Observable of the Element
    public func specifyState<E>(_ selector: @escaping (State) -> E) -> Observable<E> where E: Equatable {
        return state
            .map(selector)
            .distinctUntilChanged()
    }

    /// Specific element avoiding duplicate notifications, ignoring current element.
    /// IgnorableAction changes are not notified.
    /// - Parameter selector: the closure that allows to extract an Element
    /// - Returns: an Observable of the Element
    public func specifyNewState<E>(_ selector: @escaping (State) -> E) -> Observable<E> where E: Equatable {
        return specifyState(selector)
            .skip(1)
    }
}
