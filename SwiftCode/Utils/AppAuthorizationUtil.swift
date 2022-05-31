//
//  AppAuthorizationUtil.swift
//  YWWUtils
//
//  Created by 王金山 on 2022/5/23.
//

import UIKit
import AVFoundation
import CoreTelephony
import Photos

@objc
public class AppAuthorizationUtil: NSObject {
    
    @objc public static func checkNetwork(authorized: ((Bool) -> Void)? = nil) {
        if #available(iOS 9.0, *) {
            let cellularData = CTCellularData()
            cellularData.cellularDataRestrictionDidUpdateNotifier = { (_ state: CTCellularDataRestrictedState) -> Void in
                switch state {
                case .notRestricted:
                    authorized?(true)
                default:
                    authorized?(false)
                }
            }
        } else {
            authorized?(true)
        }
    }
    
    @objc public static func checkRecord(_ authorized: @escaping (() -> Void), denied: (() -> Void)? = nil) {
        let permission = AVAudioSession.sharedInstance()
        permission.requestRecordPermission { (result) in
            DispatchQueue.main.async {
                if result {
                    authorized()
                } else {
                    denied?()
                }
            }
        }
    }
    
    @objc public static func checkPhoto(authorized: (() -> Void)? = nil, denied: (() -> Void)? = nil) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            authorized?()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    authorized?()
                default:
                    denied?()
                }
            }
        default:
            denied?()
        }
    }
    
    @objc public static func requestAccessForCamera(authorized: (() -> Void)? = nil,
                                                    denied: (() -> Void)? = nil,
                                                    cancleCallback: (() -> Void)? = nil,
                                                    sureCallback: (() -> Void)? = nil) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (determined) in
                DispatchQueue.main.async {
                    if !determined {
                        cancleCallback?()
                    } else {
                        sureCallback?()
                    }
                }
            }
        } else if status == .authorized {
            authorized?()
        } else {
            denied?()
        }
    }
    
    @objc public static func jumpToAppSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @objc public static func isAuthorizedCamera() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
}
