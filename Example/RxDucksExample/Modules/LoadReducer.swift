//
//  LoadReducer.swift
//  RxDucksExample
//
//  Created by Kyohei Ito on 2018/07/20.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDucks

enum LoadAction: Action {
    case loading, progress(Int), loaded, cancel
}

extension ActionCreator {
    static func loading() -> LoadAction {
        return .loading
    }
    static func progress(_ progress: Int) -> LoadAction {
        return .progress(progress)
    }
    static func loaded() -> LoadAction {
        return .loaded
    }
    static func cancel() -> LoadAction {
        return .cancel
    }
}

struct LoadState: State {
    var progress = 0
    var loading = false
    var canceled = false
}

struct LoadReducer {
    static func reduce(_ state: LoadState, action: Action) -> LoadState {
        switch action {
        case is LogOutAction:
            return LoadState(progress: 0, loading: state.loading, canceled: false)
        default:
            break
        }

        switch action as? LoadAction {
        case .loading?:
            return LoadState(progress: 0, loading: true, canceled: false)
        case .progress(let progress)?:
            return LoadState(progress: progress, loading: state.loading, canceled: false)
        case .loaded?:
            return LoadState(progress: state.progress, loading: false, canceled: false)
        case .cancel?:
            return LoadState(progress: 0, loading: false, canceled: true)
        default:
            break
        }

        return state
    }
}

struct LoadMiddleware: Middleware {
    private let cancel = PublishRelay<Void>()

    func on(_ store: Store<AppState>, action: Action, next: @escaping (Action) -> Void) -> Disposable {
        switch action {
        case is LogInAction:
            store.dispatch(ActionCreator.loading())

            return Observable<Int>.interval(0.01, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
                .takeUntil(cancel)
                .subscribe(onNext: { progress in
                    store.dispatch(ActionCreator.progress(progress))

                    if progress >= 100 {
                        next(ActionCreator.loaded())
                    }
                })
        default:
            switch action as? LoadAction {
            case .cancel?:
                cancel.accept(())
            default:
                break
            }
            next(action)
        }

        return Disposables.create()
    }
}
