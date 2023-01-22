//
//  GlobalHelper.swift
//  TraverBool
//
//  Created by Tahir Uzelli on 22.01.2023.
//

import Foundation
import UIKit
import UserNotifications
import SafariServices
import SystemConfiguration

class GlobalHelper {
    
    // MARK: - Generic Methods
    // ================================================
    static func isSandboxMode() -> Bool {
        #if DEBUG
        return true
        #else
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        #endif
    }
    
    static func isDefaultSetted(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func openLinkInSafari(_ vc: UIViewController, url: String) {
        // for opening link safari in app and do not leave the app uncomment this block
        /*
         guard let url = URL(string: url) else { return }
         let svc = SFSafariViewController(url: url)
         present(svc, animated: true, completion: nil)
         */
        
        guard let url = URL(string: url) else { return }
        let svc = SFSafariViewController(url: url)
        vc.present(svc, animated: true, completion: nil)
        
        //        guard let url = URL(string: url) else { return }
        //        if #available(iOS 10.0, *) {
        //            UIApplication.shared.open(url)
        //        } else {
        //            UIApplication.shared.openURL(url)
        //        }
    }
    
//    static func rateAction() {
//        let urlString = "itms-apps://itunes.apple.com/app/id" + AppData.AppId + "?action=write-review"
//        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }
//
//    static func shareAction(_ vc: UIViewController) {
//        let activityController = UIActivityViewController(activityItems: [AppData.shareString], applicationActivities: nil)
//        activityController.popoverPresentationController?.sourceView = vc.view
//        vc.present(activityController, animated: true, completion: nil)
//    }

    static func showInfoAlert(_ vc: UIViewController, message: String, title: String = "") {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.popoverPresentationController?.sourceView = vc.view
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
//    static func showGenericAlert(_ vc: UIViewController, viewModel: GenericAlertViewModel) -> GenericAlertViewController {
//        let alert = UIStoryboard(name: "PopUps", bundle: nil).instantiateViewController(withIdentifier: "GenericAlertViewController") as! GenericAlertViewController
//
//        alert.viewModel = viewModel
//
//        alert.view.backgroundColor = .black.withAlphaComponent(0.4)
//        alert.modalTransitionStyle = .coverVertical
//        alert.modalPresentationStyle = .overCurrentContext
//        vc.present(alert, animated: true)
//
//        return alert
//    }

    // MARK: - Navigation Methods
    // ============================================================
    static func presentVC(_ vc: UIViewController, identifier: String, storyBoardName: String, isFullScreen: Bool = false) {
        let controller = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        if isFullScreen {
            vc.modalPresentationStyle = .overCurrentContext
        }
        vc.present(controller, animated: true, completion: nil)
    }
    
    static func pushVC(_ vc: UIViewController, identifier: String, storyBoardName: String) {
        let controller = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: identifier)
        vc.navigationController?.pushViewController(controller, animated: true)
    }
    
//    static func showVC(storyBoardName: String, VC : UIViewController, identifier: String){
//        let vc = UIStoryboard.init(name: storyBoardName, bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as? VC
//        vc.navigationController?.showDetailViewController(vc!, sender: nil)
//    }
    
    static func pushController<VC: UIViewController>(id: String,_ vC: UIViewController, storyBoardName: String, setup: (_ vc: VC) -> ()) {
      if let vc = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: id) as? VC {
        setup(vc)
          vC.navigationController?.pushViewController(vc, animated: true)
      }
    }
    
    static func push(from: UIViewController, to: UIViewController) {
        from.navigationController?.pushViewController(to, animated: true)
    }

    static func present(from: UIViewController, to: UIViewController) {
        from.present(to, animated: true, completion: nil)
    }
    
    static func setRootViewController(vc: UIViewController) {
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.rootViewController = vc
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.3
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
                { completed in
                    
            })
        }
    }
    
    static func arrayContainsArray(array1: [Int], array2: [Int])->Bool{
        let listSet = Set(array1)
        let findListSet = Set(array2)
        let allElemsContained = findListSet.isSubset(of: listSet)
        return allElemsContained
    }
    
    
    // MARK: - Reachability
    // ================================================
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }

    
}
