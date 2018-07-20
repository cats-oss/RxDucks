//
//  ViewController.swift
//  RxDucksExample
//
//  Created by Kyohei Ito on 2018/07/13.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxDucks

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let store = Store(reducer: AppReducer(), state: AppState(), middlewares: LoadMiddleware())

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = cancelButton.bounds.height / 2
        }
    }
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.startAnimating()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.specifyState { !$0.load.loading }
            .bind(to: cancelButton.rx.isHidden)
            .disposed(by: disposeBag)

        store.specifyState { !$0.load.loading }
            .bind(to: indicator.rx.isHidden)
            .disposed(by: disposeBag)

        store.specifyState { !$0.load.loading }
            .bind(to: logInButton.rx.isEnabled)
            .disposed(by: disposeBag)

        store.specifyState { $0.load.loading }
            .filter { $0 }
            .map { _ in "Loading" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        store.specifyState { Float($0.load.progress) / 100 }
            .bind(to: progress.rx.progress)
            .disposed(by: disposeBag)

        store.specifyNewState { $0.user.loggedIn }
            .map { $0 ? "Log In" : "Log Out" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        store.specifyNewState { $0.load.canceled }
            .filter { $0 }
            .map { _ in "Canceled" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        let loggedIn = logInButton.rx.tap
            .withLatestFrom(store.specifyState { $0.user.loggedIn })
            .share()

        loggedIn
            .filter { $0 }
            .map { _ in "Already Logged In" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        loggedIn
            .filter { !$0 }
            .map { _ in ActionCreator.logIn() }
            .bind(to: store.dispatcher)
            .disposed(by: disposeBag)

        let loggedOut = logOutButton.rx.tap
            .withLatestFrom(store.specifyState { !$0.user.loggedIn })
            .share()

        loggedOut
            .filter { $0 }
            .map { _ in "Already Logged Out" }
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)

        loggedOut
            .filter { !$0 }
            .map { _ in ActionCreator.logOut() }
            .bind(to: store.dispatcher)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .map { ActionCreator.cancel() }
            .bind(to: store.dispatcher)
            .disposed(by: disposeBag)
    }
}
