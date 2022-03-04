//
//  ClipImageBrowserHelper.swift
//  ClipImageBrowser
//
//  Created by 好未来山神 on 2020/12/3.
//

import UIKit

extension ClipImageBrowserController {
    enum ClipPanEdge {
        case none
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center
    }

    public enum ForcedrotateDirectionEnum {
        case up
        case left
        case down
        case right
        case unknow //用户不知道,则根据图片方向确定
    }
}

public protocol ClipImageBrowserProtocol: class {
    func clickCloseButton(controller: ClipImageBrowserController)
    func clickSureButton(controller: ClipImageBrowserController, clipImage: UIImage, clipImageRect: CGRect)
    func clickRotateButton(controller: ClipImageBrowserController)
}

public extension ClipImageBrowserProtocol {
    func clickCloseButton(controller: ClipImageBrowserController) { }
    func clickSureButton(controller: ClipImageBrowserController, clipImage: UIImage, clipImageRect: CGRect) { }
    func clickRotateButton(controller: ClipImageBrowserController) { }
}
