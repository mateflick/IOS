//
//  QRCodeGenViewController.swift
//  MateflickPhotobank
//
//  Created by Igor Ostriz on 10/10/2018.
//  Copyright © 2018 MateFlick. All rights reserved.
//


import MZFormSheetPresentationController
import UIKit


class QRCodeGenViewController: UIViewController {

    @IBOutlet weak var qrCodeView: QRCodeView!
    
    static func create() -> QRCodeGenViewController {
//        return QRCodeGenViewController(nibName: String(describing: QRCodeGenViewController.self), bundle: nil)
        let storyboard = UIStoryboard(name: Storyboard.main, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "QRCodeGenViewControllerID") as! QRCodeGenViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        qrCodeView.generateCode("Mateflick Photobank: hrrp://matflick.com")
    }
    
    
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}



extension QRCodeGenViewController:  MZFormSheetPresentationContentSizing {
    
    
    func shouldUseContentViewFrame(for presentationController: MZFormSheetPresentationController!) -> Bool {
        return true
    }
    
    func contentViewFrame(for presentationController: MZFormSheetPresentationController!, currentFrame: CGRect) -> CGRect {
        var r = currentFrame
        r.size.height = 350
        return r
    }
    
}
