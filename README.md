# :duck: RxDucks

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxDucks.svg?style=flat)](http://cocoadocs.org/docsets/RxDucks)
[![License](https://img.shields.io/cocoapods/l/RxDucks.svg?style=flat)](http://cocoadocs.org/docsets/RxDucks)
[![Platform](https://img.shields.io/cocoapods/p/RxDucks.svg?style=flat)](http://cocoadocs.org/docsets/RxDucks)

## What's RxDucks?

RxDucks is a Redux-like framework working on RxSwift. There are various Redux frameworks, this is a framework specialized for RxSwift.

Redux is one of the modern application architectures. For details, refer to the following links.

- [Redux](https://redux.js.org/)
- [About ReactiveReSwift](https://reswift.github.io/ReactiveReSwift/master/about-reactivereswift.html)


## Requirements

- Swift 4.1
- RxSwift 4.1 or later

## How to Install

#### CocoaPods

Add the following to your `Podfile`:

```Ruby
pod "RxDucks"
```

#### Carthage

Add the following to your `Cartfile`:

```Ruby
github "cats-oss/RxDucks"
```

## How to use RxDucks

The minimum required is `State`, `Action`, `Reducer` and `Store`.

### State

For `State`, prepare property that application state want. For example, when it want the counter that users can increase or decrease, should create counting property.

It does not have to make immutable necessarily.

```swift
struct AppState: State {
    var counter: Int = 0
    var user = UserState()
}

struct UserState: State {
    var loggedIn = false
}
```

### Action

Prepare actions for increase and decrease.

```swift
struct IncreaseAction: Action {}
struct DecreaseAction: Action {}
struct LogInAction: Action {}
```

It does not matter whether it is a struct or not, as long as it complies with the `Action` protocol.

```swift
enum CounterAction: Action {
    case increase, decrease
}
```

If it does not want to notify state to store, use `IgnorableAction`.

```swift
struct ResetAction: IgnorableAction {}
```

### Reducer

Have to prepare Reducer that complies with the Reducer protocol.

```swift
struct AppReducer: Reducer {
    func reduce(_ state: AppState, action: Action) -> AppState {
        var state = state

        switch action {
        case is IncreaseAction:
            state.counter += 1
        case is DecreaseAction:
            state.counter -= 1
        case is ResetAction:
            state.counter = 0
        case id LogInAction:
            state.user.loggedIn = true
        default:
            break
        }

        return state
    }
}
```

It possible that calls the reducer in main reducer. In that case, it is not necessary to conform to the `Reducer` protocol.

```swift
struct CounterReduder {
    static func reduce(_ state: Int, action: Action) -> Int {
        switch action {
        case is IncreaseAction:
            return state + 1
        case is DecreaseAction:
            return state - 1
        case is ResetAction:
            return 0
        default:
            return state
        }
    }
}

struct UserReduder {
    static func reduce(_ state: UserState, action: Action) -> UserState {
        switch action {
        case is LogInAction:
            return UserState(loggedIn: true)
        default:
            return state
        }
    }
}

struct AppReducer: Reducer {
    func reduce(_ state: AppState, action: Action) -> AppState {
        return AppState(counter: CounterReduder.reduce(state.counter, action: action),
                        user: UserReduder.reduce(state.user, action: action))
    }
}
```

### Store

Initialize with the initial state and the instance of the main `Reducer`.

```swift
let store = Store(reducer: AppReducer(), state: AppState())
```

It can also make the shared instance.

```swift
extension Store where State == AppState {
    static let shared = Store(reducer: AppReducer(), state: AppState())
}
```

#### Subscribe to the state

It can subscribe to change the state. `state` subscribes all change. `specifyState` subscribes specific state change. Then, when the `Store` subscribes to `state` and `specifyState`, it observes the current state, but when subscribes to `newState` and `specifyNewState`, it does not observe the current state.

```swift
class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let store = Store(reducer: AppReducer(), state: AppState())

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        store.state
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)

        store.specifyNewState { $0.user.loggedIn }
            .map { $0 ? "Log In" : "Log Out" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        store.specifyState { $0.counter }
            .map { "\($0)" }
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
```

#### Dispatch an action

It can dispatch an action to mutate the state.

```swift
store.dispatch(IncreaseAction())
```

Also, it possible to bind using `dispatcher`.

```swift
class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let store = Store(reducer: AppReducer(), state: AppState())

    @IBOutlet weak var increaseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        increaseButton.rx.tap
            .map { IncreaseAction() }
            .bind(to: store.dispatcher)
            .disposed(by: disposeBag)
    }
}
```

### Middleware

It is similar to Reducer, but it can not mutate the state. What `Middleware` can do is to dispatch and change new Actions.

```swift
struct LoggingMiddleware: Middleware {
    func on(_ store: Store<AppState>, action: Action, next: @escaping (Action) -> Void) -> Disposable {
        print(action)
        next(action)
        return Disposables.create()
    }
}
```

The reason for returning `Disposable` is to facilitate asynchronous processing. It has to execute `next` closure. So if catch some error, should also execute it.

```swift
struct LoginMiddleware: Middleware {
    func on(_ store: Store<AppState>, action: Action, next: @escaping (Action) -> Void) -> Disposable {
        switch action {
        case is LogInAction:
            store.dispatch(LoadingAction())

            let request = URLRequest(url: URL(string: "YOUR_URL")!)
            return URLSession.shared.rx.data(request: request)
                .subscribe(onNext: {
                    next(LoadedAction(data: $0))
                }, onError: {
                    next(LoadErrorAction(error: $0))
                })
        default:
            next(action)
        }

        return Disposables.create()
    }
}
```

Multiple `Middleware` can be created. They are executed in the order they were created.

```swift
let shared = Store(reducer: AppReducer(), state: AppState(), middlewares: LoggingMiddleware(), LoginMiddleware())
```

## LICENSE
Under the MIT license. See LICENSE file for details.
