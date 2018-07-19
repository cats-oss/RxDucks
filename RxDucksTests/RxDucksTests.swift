//
//  RxDucksTests.swift
//  RxDucksTests
//
//  Created by Kyohei Ito on 2018/07/12.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import XCTest
@testable import RxDucks
import RxSwift
import RxCocoa

class RxDucksTests: XCTestCase {
    var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
    }

    func testInitialize() {
        let state = TestState(int: 10, string: "test")
        let store1 = Store<TestState>(reducer: TestReducer(), state: state)
        XCTAssertEqual(store1.currentState.int, 10)
        XCTAssertEqual(store1.currentState.string, "test")

        let store2 = Store<TestState>(reducer: TestReducer(), state: state, middlewares: [])
        XCTAssertEqual(store2.currentState.int, 10)
        XCTAssertEqual(store2.currentState.string, "test")
    }

    func testState() {
        let state = BehaviorRelay<TestState?>(value: nil)
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: TestMiddleware())
        store.state
            .bind(to: state)
            .disposed(by: disposeBag)

        XCTAssertEqual(state.value?.int, 0)
        XCTAssertEqual(state.value?.string, "")

        store.dispatch(TestAction(int: 5, string: "A"))

        XCTAssertEqual(state.value?.int, 5)
        XCTAssertEqual(state.value?.string, "A")

        store.dispatch(IgnoreAction(int: 10, string: "B"))

        XCTAssertEqual(state.value?.int, 5)
        XCTAssertEqual(state.value?.string, "A")

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "B")
    }

    func testNewState() {
        let state = BehaviorRelay<TestState?>(value: nil)
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: TestMiddleware())
        store.newState
            .bind(to: state)
            .disposed(by: disposeBag)

        XCTAssertNil(state.value?.int)
        XCTAssertNil(state.value?.string)

        store.dispatch(TestAction(int: 5, string: "A"))

        XCTAssertEqual(state.value?.int, 5)
        XCTAssertEqual(state.value?.string, "A")

        store.dispatch(IgnoreAction(int: 10, string: "B"))

        XCTAssertEqual(state.value?.int, 5)
        XCTAssertEqual(state.value?.string, "A")

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "B")
    }

    func testSpecifyState() {
        let int = BehaviorRelay<Int?>(value: nil)
        let string = BehaviorRelay<String?>(value: nil)
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: TestMiddleware())

        store
            .specifyState { $0.int }
            .bind(to: int)
            .disposed(by: disposeBag)

        store
            .specifyState { $0.string }
            .bind(to: string)
            .disposed(by: disposeBag)

        XCTAssertEqual(int.value, 0)
        XCTAssertEqual(string.value, "")

        store.dispatch(TestAction(int: 5, string: "A"))

        XCTAssertEqual(int.value, 5)
        XCTAssertEqual(string.value, "A")

        store.dispatch(TestAction(int: 10, string: "A"))

        XCTAssertEqual(int.value, 10)
        XCTAssertEqual(string.value, "A")

        int.accept(nil)
        string.accept(nil)

        store.dispatch(TestAction(int: 10, string: "A"))

        XCTAssertNil(int.value)
        XCTAssertNil(string.value)

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "A")

        store.dispatch(IgnoreAction(int: 10, string: "B"))

        XCTAssertNil(int.value)
        XCTAssertNil(string.value)

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "B")
    }

    func testSpecifyNewState() {
        let int = BehaviorRelay<Int?>(value: nil)
        let string = BehaviorRelay<String?>(value: nil)
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: TestMiddleware())

        store
            .specifyNewState { $0.int }
            .bind(to: int)
            .disposed(by: disposeBag)

        store
            .specifyNewState { $0.string }
            .bind(to: string)
            .disposed(by: disposeBag)

        XCTAssertNil(int.value)
        XCTAssertNil(string.value)

        store.dispatch(TestAction(int: 5, string: "A"))

        XCTAssertEqual(int.value, 5)
        XCTAssertEqual(string.value, "A")

        store.dispatch(TestAction(int: 10, string: "A"))

        XCTAssertEqual(int.value, 10)
        XCTAssertEqual(string.value, "A")

        int.accept(nil)
        string.accept(nil)

        store.dispatch(TestAction(int: 10, string: "A"))

        XCTAssertNil(int.value)
        XCTAssertNil(string.value)

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "A")

        store.dispatch(IgnoreAction(int: 10, string: "B"))

        XCTAssertNil(int.value)
        XCTAssertNil(string.value)

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "B")
    }

    func testActionCreator() {
        XCTAssertEqual(ActionCreator().ignore(10, "A"), IgnoreAction(int: 10, string: "A"))
        XCTAssertEqual(ActionCreator().test(10, "A"), TestAction(int: 10, string: "A"))
    }

    func testMiddleware() {
        let middleware1 = TestMiddleware()
        let middleware2 = TestMiddleware()
        let middleware3 = TestMiddleware()
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: middleware1, middleware2, middleware3)
        store.dispatch(IncreaseAction(count: 0))

        XCTAssertEqual(middleware1.count, 1)
        XCTAssertEqual(middleware2.count, 2)
        XCTAssertEqual(middleware3.count, 3)
    }

    func testMiddlewareType() {
        struct A: Action, Equatable {}
        struct S: State {}
        struct R: Reducer {
            func reduce(_ state: S, action: Action) -> S {
                return S()
            }
        }
        struct M: Middleware {
            func on(_ store: Store<S>, action: Action, next: @escaping (Action) -> Void) -> Disposable {
                next(A())
                return Disposables.create()
            }
        }

        _ = M().on(Store<S>(reducer: R(), state: S()), action: TestAction(int: 0, string: "")) { action in
            XCTAssertEqual(action as? A, A())
        }

        _ = M().on(Store<TestState>(reducer: TestReducer(), state: TestState()), action: TestAction(int: 0, string: "")) { action in
            XCTAssertNotEqual(action as? A, A())
        }
    }

    func testDispatcher() {
        let state = BehaviorRelay<TestState?>(value: nil)
        let store = Store<TestState>(reducer: TestReducer(), state: TestState(), middlewares: TestMiddleware())
        store.state
            .bind(to: state)
            .disposed(by: disposeBag)

        XCTAssertEqual(state.value?.int, 0)
        XCTAssertEqual(state.value?.string, "")

        store.dispatch(TestAction(int: 5, string: "A"))

        XCTAssertEqual(state.value?.int, 5)
        XCTAssertEqual(state.value?.string, "A")

        store.dispatcher.onNext(TestAction(int: 10, string: "B"))

        XCTAssertEqual(store.currentState.int, 10)
        XCTAssertEqual(store.currentState.string, "B")
    }
}

class TestMiddleware: Middleware {
    var count = 0
    func on(_ store: Store<TestState>, action: Action, next: @escaping (Action) -> Void) -> Disposable {
        switch action {
        case let action as IncreaseAction:
            count = action.count + 1
            next(IncreaseAction(count: count))
        default:
            next(action)
        }

        return Disposables.create()
    }
}

extension ActionCreator {
    func ignore(_ int: Int, _ string: String) -> IgnoreAction {
        return IgnoreAction(int: int, string: string)
    }

    func test(_ int: Int, _ string: String) -> TestAction {
        return TestAction(int: int, string: string)
    }
}

struct IncreaseAction: Action {
    let count: Int
}

struct IgnoreAction: IgnorableAction, Equatable {
    let int: Int
    let string: String
}

struct TestAction: Action, Equatable {
    let int: Int
    let string: String
}

struct TestState: State, Equatable {
    var int = 0
    var string = ""
}

class TestReducer: Reducer {
    func reduce(_ state: TestState, action: Action) -> TestState {
        switch action {
        case let action as TestAction:
            return TestState(int: action.int, string: action.string)
        case let action as IgnoreAction:
            return TestState(int: action.int, string: action.string)
        default:
            return TestState()
        }
    }
}
