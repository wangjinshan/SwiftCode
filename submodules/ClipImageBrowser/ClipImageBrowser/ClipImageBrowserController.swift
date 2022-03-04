//
//  ClipImageBrowserController.swift
//  ClipImageBrowser
//
//  Created by 好未来山神 on 2020/12/1.
//

import UIKit

open class ClipImageBrowserController: UIViewController {

    public weak var delegate: ClipImageBrowserProtocol?
    public var bottomViewHeight: CGFloat = 125
    public var leftMargin: CGFloat = 16
    public var closeButtonTopMargin: CGFloat = 4
    public var topMargin: CGFloat = 20
    public var closeButtonSize: CGSize = CGSize(width: 32, height: 32)
    public var minClipSize = CGSize(width: 40, height: 40)
    public var tipTitle: String? = "一次框选一道题，解析更精准"
    public private(set) var clipImage: UIImage?
    public private(set) var clipImageRect: CGRect?

    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    private let insetWidth: CGFloat = 20
    private let originalImage: UIImage
    private let tipDirection: ClipImageBrowserController.ForcedrotateDirectionEnum

    private var direction: ClipImageBrowserController.ForcedrotateDirectionEnum
    private var editImage: UIImage
    private var angle: CGFloat = 0

    private var beginPanPoint: CGPoint = .zero
    private var clipBoxFrame: CGRect = .zero
    private var clipOriginFrame: CGRect = .zero
    private var isRotating = false
    private var panEdge: ClipImageBrowserController.ClipPanEdge = .none

    private var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    }

    private var maxContainerViewSize: CGSize {
        return CGSize(width: screenWidth - 2 * leftMargin, height: screenHeight - bottomViewHeight - safeAreaInsets.top - topMargin)
    }

    private var imageViewCenter: CGPoint {
        return CGPoint(x: containerView.bounds.width / 2, y: containerView.bounds.height / 2)
    }

    private var clipBoxDefaultSize: CGSize {
        switch direction {
        case .up, .unknow:
            return CGSize(width: previewSize.width, height: min(160, previewSize.height))
        case .left:
            return CGSize(width: min(160, previewSize.width), height: previewSize.height)
        case .down:
            return CGSize(width: previewSize.width, height: min(160, previewSize.height))
        case .right:
            return CGSize(width: min(160, previewSize.width), height: previewSize.height)
        }
    }

    private var previewSize: CGSize {
        var width: CGFloat = 1
        var height: CGFloat = 1
        let imageWidth = editImage.size.width
        let imageHeight = editImage.size.height
        let widthSpace = fabsf(Float(maxImageWidth - imageWidth))
        let heightSpace = fabsf(Float(maxImageHeight - imageHeight))
        if widthSpace >= heightSpace { //宽图
            if maxImageWidth > imageWidth {
                width = imageWidth * (maxImageHeight / imageHeight)
                height = imageHeight * (maxImageHeight / imageHeight)
            } else {
                width = maxImageWidth
                height = maxImageWidth * (imageHeight / imageWidth)
            }
        } else {
            if maxImageHeight > imageHeight { //竖长图
                width = imageWidth * (maxImageWidth / imageWidth)
                height = imageHeight * (maxImageWidth / imageWidth)
            } else {
                width = maxImageHeight * (imageWidth / imageHeight)
                height = maxImageHeight
                if width > maxImageWidth { // 竖图等比高存在宽越界的情形当横图处理
                    width = maxImageWidth
                    height = maxImageWidth * (imageHeight / imageWidth)
                }
            }
        }
        return CGSize(width: max(minClipSize.width, width), height: max(minClipSize.height, height))
    }

    private lazy var maxImageWidth: CGFloat = {
        return screenWidth - self.leftMargin * 2
    }()

    lazy var maxImageHeight: CGFloat = {
        return screenHeight - topMargin - safeAreaInsets.top - bottomViewHeight
    }()

    public init(image: UIImage, direction: ForcedrotateDirectionEnum? = nil) {
        self.originalImage = image
        self.editImage = originalImage
        self.direction = direction ?? .unknow
        self.tipDirection = direction ?? .up
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        configDefaultParameter()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        callbackAction()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutInitialImage()
        bottomToolView.frame = CGRect(x: 0, y: screenHeight - bottomViewHeight, width: screenWidth, height: bottomViewHeight)
        closeButton.frame = CGRect(x: leftMargin, y: closeButtonTopMargin + safeAreaInsets.top, width: closeButtonSize.width, height: closeButtonSize.height)

        tipLabel.frame = CGRect(x: leftMargin, y: containerView.frame.size.height - insetWidth - 30, width: screenWidth - 32, height: 22)
        if tipDirection == .right  || tipDirection == .left {
            let centerPoint = CGPoint(x: 30, y: imageViewCenter.y)
            tipLabel.center = centerPoint
            tipLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            bottomToolView.rotateButton(direction: tipDirection)
        }
    }

    public let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(name: "icon_32px_close"), for: .normal)
        return button
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: self.editImage)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    public let bottomToolView = ClipImageBottomView()

    private let overlayView: ClipImageClipOverlayView = {
        let view = ClipImageClipOverlayView()
        view.isUserInteractionEnabled = false
        return view
    }()

    private let tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let shadowView: ClipImageBrowserShadowView = {
        let view = ClipImageBrowserShadowView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
}

// MARK: - 手势处理
extension ClipImageBrowserController {
    @objc private func panClipView(_ pan: UIPanGestureRecognizer) {
        let point = pan.location(in: pan.view)
        if pan.state == .began {
            beginPanPoint = point
            clipOriginFrame = clipBoxFrame
            panEdge = calculatePanEdge(at: point)
        } else if pan.state == .changed {
            guard panEdge != .none else { return }
            updateClipBoxFrame(point: point)
        } else if pan.state == .cancelled || pan.state == .ended {
            self.panEdge = .none
        }
    }

    private func calculatePanEdge(at point: CGPoint) -> ClipImageBrowserController.ClipPanEdge {
        let frame = clipBoxFrame.insetBy(dx: -insetWidth, dy: -insetWidth)
        let cornerSize = CGSize(width: insetWidth * 2, height: insetWidth * 2)
        let topLeftRect = CGRect(origin: frame.origin, size: cornerSize)
        if topLeftRect.contains(point) {
            return .topLeft
        }

        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY), size: cornerSize)
        if topRightRect.contains(point) {
            return .topRight
        }

        let bottomLeftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }

        let bottomRightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.maxY - cornerSize.height), size: cornerSize)
        if bottomRightRect.contains(point) {
            return .bottomRight
        }

        let topRect = CGRect(origin: CGPoint(x: frame.minX + cornerSize.width, y: frame.minY),
                             size: CGSize(width: frame.width - 2 * cornerSize.width, height: cornerSize.height + insetWidth))
        if topRect.contains(point) {
            return .top
        }

        let bottomRect = CGRect(origin: CGPoint(x: frame.minX + cornerSize.width, y: frame.maxY - cornerSize.height),
                                size: CGSize(width: frame.width - 2 * cornerSize.width, height: cornerSize.height + insetWidth))
        if bottomRect.contains(point) {
            return .bottom
        }

        let leftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY + cornerSize.height),
                              size: CGSize(width: cornerSize.width, height: frame.height - 2 * cornerSize.height))
        if leftRect.contains(point) {
            return .left
        }

        let rightRect = CGRect(origin: CGPoint(x: frame.maxX - cornerSize.width, y: frame.minY + cornerSize.height),
                               size: CGSize(width: cornerSize.width, height: frame.height - 2 * cornerSize.height))
        if rightRect.contains(point) {
            return .right
        }

        let centerRect = CGRect(origin: CGPoint(x: frame.minX + cornerSize.width, y: frame.minY + cornerSize.height),
                                size: CGSize(width: frame.size.width - 2 * cornerSize.width, height: frame.size.height - 2 * cornerSize.height))
        if centerRect.contains(point) {
            return .center
        }
        return .none
    }

    private func updateClipBoxFrame(point: CGPoint) {
        var frame = clipBoxFrame
        let originFrame = clipOriginFrame

        let diffX = ceil(point.x - beginPanPoint.x)
        let diffY = ceil(point.y - beginPanPoint.y)

        switch panEdge {
        case .left:
            frame.origin.x = originFrame.minX + diffX
            frame.size.width = originFrame.width - diffX
        case .right:
            frame.size.width = originFrame.width + diffX
        case .top:
            frame.origin.y = originFrame.minY + diffY
            frame.size.height = originFrame.height - diffY
        case .bottom:
            frame.size.height = originFrame.height + diffY
        case .topLeft:
            frame.origin.x = originFrame.minX + diffX
            frame.size.width = originFrame.width - diffX
            frame.origin.y = originFrame.minY + diffY
            frame.size.height = originFrame.height - diffY
        case .topRight:
            frame.size.width = originFrame.width + diffX
            frame.origin.y = originFrame.minY + diffY
            frame.size.height = originFrame.height - diffY
        case .bottomLeft:
            frame.origin.x = originFrame.minX + diffX
            frame.size.width = originFrame.width - diffX
            frame.size.height = originFrame.height + diffY
        case .bottomRight:
            frame.size.width = originFrame.width + diffX
            frame.size.height = originFrame.height + diffY
        case .center:
            frame.origin.x = originFrame.minX + diffX
            frame.origin.y = originFrame.minY + diffY
        default:
            break
        }

        let minSize = CGSize(width: minClipSize.height, height: minClipSize.height)
        let maxSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
        let maxClipFrame = CGRect(origin: CGPoint(x: imageView.frame.minX, y: imageView.frame.minY), size: maxSize)

        frame.size.width = min(maxSize.width, max(minSize.width, frame.size.width))
        frame.size.height = min(maxSize.height, max(minSize.height, frame.size.height))

        let moveMaxX = maxClipFrame.maxX - frame.size.width
        let moveMaxY = maxClipFrame.maxY - frame.size.height

        let panMinX = min(maxClipFrame.maxX - minSize.width, max(frame.origin.x, maxClipFrame.minX))
        let panMinY = min(maxClipFrame.maxY - minSize.height, max(frame.origin.y, maxClipFrame.minY))

        frame.origin.x = min(moveMaxX, panMinX)
        frame.origin.y = min(moveMaxY, panMinY)

        if (panEdge == .topLeft || panEdge == .bottomLeft || panEdge == .left) &&
            frame.size.width <= minSize.width + CGFloat.ulpOfOne {
            frame.origin.x = originFrame.maxX - minSize.width
        }
        if (panEdge == .topLeft || panEdge == .topRight || panEdge == .top) &&
            frame.size.height <= minSize.height + CGFloat.ulpOfOne {
            frame.origin.y = originFrame.maxY - minSize.height
        }

        changeClipBoxFrame(newFrame: frame)
    }

    private func changeClipBoxFrame(newFrame: CGRect) {
        clipBoxFrame = newFrame
        overlayView.frame = newFrame
        shadowView.clearRect = newFrame
    }
}

// MARK: - 旋转
extension ClipImageBrowserController {
    private func rotateImageView() {
        guard !isRotating else { return }
        angle -= 90
        if angle == -360 {
            angle = 0
        }
        isRotating = true

        let animateImageView = UIImageView(image: editImage)
        animateImageView.contentMode = .scaleAspectFit
        animateImageView.clipsToBounds = true
        animateImageView.frame = imageView.frame
        containerView.addSubview(animateImageView)
        containerView.bringSubviewToFront(tipLabel)
        resetDirection()
        resetEditImage()

        imageView.image = editImage

        imageView.frame.size =  previewSize
        imageView.center = imageViewCenter

        overlayView.frame.size = clipBoxDefaultSize
        overlayView.center = imageViewCenter
        shadowView.clearRect = overlayView.frame

        imageView.alpha = 0
        overlayView.alpha = 0
        shadowView.alpha = 0

        let toFrame = CGRect(origin: imageView.frame.origin, size: previewSize)
        UIView.animate(withDuration: 0.3, animations: {
            animateImageView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            animateImageView.frame = toFrame
        }) { (_) in
            self.isRotating = false
            animateImageView.removeFromSuperview()
            self.imageView.alpha = 1
            self.overlayView.alpha = 1
            self.clipBoxFrame = self.overlayView.frame
            self.shadowView.alpha = 1
        }
    }

    private func resetDirection() {
        if angle == 0 {
            direction = .up
        } else if angle == -90 {
            direction = .left
        } else if angle == -180 {
            direction = .down
        } else if angle == -270 {
            direction = .right
        }
    }

    private func resetEditImage() {
        switch direction {
        case .up, .unknow:
            editImage = originalImage
        case .left:
            editImage = originalImage.rotate(orientation: .left)
        case .down:
            editImage = originalImage.rotate(orientation: .down)
        case .right:
            editImage = originalImage.rotate(orientation: .right)
        }
    }
}

// MARK: - 裁剪相关
extension ClipImageBrowserController {
    private func clipImageAction() -> (clipImage: UIImage, editRect: CGRect) {
        let frame = convertClipRectToEditImageRect()
        let origin = CGPoint(x: -frame.minX, y: -frame.minY) //不明白为啥
        UIGraphicsBeginImageContextWithOptions(frame.size, false, editImage.scale)
        editImage.draw(at: origin)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return (editImage, CGRect(origin: .zero, size: editImage.size))
        }
        let newImage = UIImage(cgImage: cgi, scale: editImage.scale, orientation: .up)
        return (newImage, frame)
    }

    private func convertClipRectToEditImageRect() -> CGRect {
        let x = overlayView.frame.origin.x - imageView.frame.origin.x
        let y = overlayView.frame.origin.y - imageView.frame.origin.y
        let imageWidthScale = editImage.size.width / imageView.frame.size.width
        let imageHeightScale = editImage.size.height / imageView.frame.size.height

        let overViewWidth = overlayView.frame.width
        let overViewHeight = overlayView.frame.height

        var frame = CGRect.zero
        frame.origin.x = max(0, x * imageWidthScale)
        frame.origin.y = max(0, y * imageHeightScale)
        frame.size.width = overViewWidth * imageWidthScale
        frame.size.height = overViewHeight * imageHeightScale

        return frame
    }
}

// MARK: - 初始化相关
extension ClipImageBrowserController {
    private func configDefaultParameter() {
        switch direction {
        case .up:
            angle = 0
            editImage = originalImage
        case .left:
            angle = -90
            editImage = originalImage.rotate(orientation: .left)
        case .down:
            angle = -180
            editImage = originalImage.rotate(orientation: .down)
        case .right:
            angle = -270
            editImage = originalImage.rotate(orientation: .right)
        case .unknow:
            configDefaultUnkonwDirection()
        }
    }

    private func configDefaultUnkonwDirection() {
        switch originalImage.imageOrientation {
        case .up, .upMirrored:
            direction = .up
        case .left, .leftMirrored:
            direction = .left
        case .down, .downMirrored:
            direction = .down
        case .right, .rightMirrored:
            direction = .right
        default:
            direction = .up
        }
        configDefaultParameter()
    }

    private func callbackAction() {
        bottomToolView.clickrotateCallback = { [weak self] in
            guard let `self` = self else { return }
            self.rotateImageView()
            self.delegate?.clickRotateButton(controller: self)
        }
        bottomToolView.clickSureCallback = { [weak self] in
            guard let `self` = self else { return }
            let result = self.clipImageAction()
            self.clipImage = result.clipImage
            self.clipImageRect = result.editRect
            self.delegate?.clickSureButton(controller: self, clipImage: result.clipImage, clipImageRect: result.editRect)
            self.closeController(animated: false)
        }
    }

    @objc private func clickCloseButton() {
        delegate?.clickCloseButton(controller: self)
        closeController()
    }

    private func closeController(animated: Bool = true) {
        if let navigation = navigationController {
            navigation.popViewController(animated: animated)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UI
extension ClipImageBrowserController {
    private func setupUI() {
        view.backgroundColor = UIColor.black
        view.addSubview(bottomToolView)
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(shadowView)
        containerView.addSubview(overlayView)
        containerView.addSubview(tipLabel)
        tipLabel.text = tipTitle
        view.addSubview(closeButton)

        closeButton.addTarget(self, action: #selector(clickCloseButton), for: .touchUpInside)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panClipView(_:)))
        containerView.addGestureRecognizer(pan)
    }

    func layoutInitialImage() {
        containerView.frame = CGRect(x: 0,
                                     y: topMargin + safeAreaInsets.top - insetWidth,
                                     width: screenWidth,
                                     height: screenHeight - (topMargin + safeAreaInsets.top) - bottomViewHeight + 2 * insetWidth)
        imageView.frame = CGRect(origin: .zero, size: previewSize)
        imageView.center = imageViewCenter
        shadowView.frame = containerView.bounds
        overlayView.frame = CGRect(origin: .zero, size: clipBoxDefaultSize)
        overlayView.center = imageViewCenter
        changeClipBoxFrame(newFrame: overlayView.frame)
    }
}

// MARK: - ClipMoreImageShadowView
class ClipImageBrowserShadowView: UIView {

    var clearRect: CGRect = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        UIColor(white: 0, alpha: 0.7).setFill()
        UIRectFill(rect)
        let cr = self.clearRect.intersection(rect)
        UIColor.clear.setFill()
        UIRectFill(cr)
    }
}
