//
//  Feature.swift
//  wandAR
//
//  Created by Jyoti Arora on 11/12/17.
//  Copyright © 2017 Jyoti Arora. All rights reserved.
//

import Foundation

struct Feature {
    var logic: FeatureLogicProtocol
    var dependencies: [FeatureName]?
    var view: FeatureViewProtocol?
    var viewOrder: Int?
}

// swiftlint:disable identifier_name
enum FeatureName {
    case CameraFeature
    case LevelMenuFeature
    case ConnectDotsGameFeature
    case FiddleFeature
}
// swiftlint:enable identifier_name

protocol FeatureLogicProtocol: class {
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName: FeatureLogicProtocol]?)
    func willAppear(_ animated: Bool)
    func willDisappear(_ animated: Bool)
    func applicationDidEnterBackground()
    func applicationDidEnterForeground()
    func dispose()
}

extension FeatureLogicProtocol {
    func willAppear(_ animated: Bool) {}
    func willDisappear(_ animated: Bool) {}
    func applicationDidEnterBackground() {}
    func applicationDidEnterForeground() {}
    func dispose() {}
}

protocol FeatureViewProtocol: class {
    func show(_ onShowing: (() -> Void)?)
    func hide(_ onHidden: (() -> Void)?)
    func removeFromSuperview()
}

extension FeatureViewProtocol {
    func show(_ onShowing: (() -> Void)?) {
        onShowing?()
    }
    func hide(_ onHidden: (() -> Void)?) {
        onHidden?()
    }
}
