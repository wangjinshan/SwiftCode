//
//  ClipImageBrowserView.swift
//  ClipImageBrowser
//
//  Created by 好未来山神 on 2020/12/1.
//

import UIKit

// MARK: - 底部工具条
open class ClipImageBottomView: UIView {

    public var clickSureCallback: (() -> Void)?
    public var clickrotateCallback: (() -> Void)?

    public let sureButtonWidth: CGFloat = 70
    public let sureButtonTopMargin: CGFloat = 25
    public let rotateButtonRightMargin: CGFloat = 32
    public let rotateButtonWidth: CGFloat = 40
    public let rotateButtonTopMargin: CGFloat = 40

    private var sureImage = UIImage(name: "img_camerabtn_confirm")
    private var rotateImage = UIImage(name: "icon_40px_rotate")

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        addSubview(sureButton)
        addSubview(rotateButton)
        sureButton.addTarget(self, action: #selector(clickSureButton), for: .touchUpInside)
        rotateButton.addTarget(self, action: #selector(clickrotateButton), for: .touchUpInside)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func rotateButton(direction: ClipImageBrowserController.ForcedrotateDirectionEnum) {
        var orientation: UIImage.Orientation = .up
        switch direction {
        case .up:
            orientation = .up
        case .left:
            orientation = .left
        case .down:
            orientation = .down
        case .right:
            orientation = .right
        default:
            orientation = .up
        }
        sureImage = sureImage?.rotate(orientation: orientation)
        rotateImage = rotateImage?.rotate(orientation: orientation)
        resetButtonImage()
    }

    @objc private func clickSureButton() {
        clickSureCallback?()
    }

    @objc private func clickrotateButton() {
        clickrotateCallback?()
    }

    private func resetButtonImage() {
        sureButton.setImage(sureImage, for: .normal)
        rotateButton.setImage(rotateImage, for: .normal)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.size.width
        sureButton.frame = CGRect(x: width / 2 - sureButtonWidth / 2, y: sureButtonTopMargin, width: sureButtonWidth, height: sureButtonWidth)
        rotateButton.frame = CGRect(x: width - rotateButtonRightMargin - rotateButtonWidth, y: rotateButtonTopMargin, width: rotateButtonWidth, height: rotateButtonWidth)
    }

    public lazy var sureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(self.sureImage, for: .normal)
        return button
    }()

    public lazy var rotateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(self.rotateImage, for: .normal)
        return button
    }()
}

// MARK: 裁剪网格视图
class ClipImageClipOverlayView: UIView {

    static let lineWidth: CGFloat = 2
    let boldLineLength: CGFloat = 20
    let boldLineWidth: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(ClipImageClipOverlayView.lineWidth)

        context?.beginPath()
        //上横
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: rect.size.width, y: 0))
        // 右竖
        context?.move(to: CGPoint(x: rect.size.width, y: 0))
        context?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        //下横
        context?.move(to: CGPoint(x: rect.size.width, y: rect.size.height))
        context?.addLine(to: CGPoint(x: 0, y: rect.size.height))
        //左竖
        context?.move(to: CGPoint(x: 0, y: rect.size.height))
        context?.addLine(to: CGPoint(x: 0, y: 0))

        // 块
        context?.strokePath()
        context?.setLineWidth(boldLineWidth)
        // 左上
        context?.move(to: CGPoint(x: 0, y: 1.5))
        context?.addLine(to: CGPoint(x: boldLineLength, y: 1.5))

        context?.move(to: CGPoint(x: 1.5, y: 0))
        context?.addLine(to: CGPoint(x: 1.5, y: boldLineLength))

        // 右上
        context?.move(to: CGPoint(x: rect.width-boldLineLength, y: 1.5))
        context?.addLine(to: CGPoint(x: rect.width, y: 1.5))

        context?.move(to: CGPoint(x: rect.width - 1.5, y: 0))
        context?.addLine(to: CGPoint(x: rect.width - 1.5, y: boldLineLength))

        // 左下
        context?.move(to: CGPoint(x: 1.5, y: rect.height - boldLineLength))
        context?.addLine(to: CGPoint(x: 1.5, y: rect.height))

        context?.move(to: CGPoint(x: 0, y: rect.height - 1.5))
        context?.addLine(to: CGPoint(x: boldLineLength, y: rect.height - 1.5))

        // 右下
        context?.move(to: CGPoint(x: rect.width - boldLineLength, y: rect.height - 1.5))
        context?.addLine(to: CGPoint(x: rect.width, y: rect.height - 1.5))

        context?.move(to: CGPoint(x: rect.width - 1.5, y: rect.height - boldLineLength))
        context?.addLine(to: CGPoint(x: rect.width - 1.5, y: rect.height))

        context?.strokePath()
        context?.setShadow(offset: CGSize(width: 1, height: 1), blur: 0)
    }
}
