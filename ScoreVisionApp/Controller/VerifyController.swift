//
//  VerifyController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/19/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

final class VerifyViewController: UIViewController {

    @IBOutlet weak var nosasha: UIImageView!
    
    //MARK  the images on the left has been enrolled ot the API, check enrol example for documentation.
    
    @IBOutlet weak var sasha1: UIImageView!
    @IBOutlet weak var sasha2: UIImageView!
    @IBOutlet weak var sasha3: UIImageView!
    @IBOutlet weak var sasha5: UIImageView!
    @IBOutlet weak var sasha6: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func verify1(_ sender: UITapGestureRecognizer) {
        
        guard let imageToVerify = sasha2.image else { return }
        KairosAPI.sharedInstance.exampleVerify(imageToVerify).then { (text, isSubject) in
            self.highlight(self.sasha1, leftIV: self.sasha2, isSubject: isSubject)
        }
    }
    
    @IBAction func verify2(_ sender: UITapGestureRecognizer) {
        guard let imageToVerify = nosasha.image else { return }
        KairosAPI.sharedInstance.exampleVerify(imageToVerify).then { (text, isSubject) in
            self.highlight(self.sasha3, leftIV: self.nosasha, isSubject: isSubject)
        }
    }
    
    @IBAction func verify3(_ sender: UITapGestureRecognizer) {
        guard let imageToVerify = sasha6.image else { return }
        KairosAPI.sharedInstance.exampleVerify(imageToVerify).then { (text, isSubject) in
            self.highlight(self.sasha6, leftIV: self.sasha5, isSubject: isSubject)
        }
    }
    
    private func highlight(_ rightIV: UIImageView, leftIV: UIImageView, isSubject: Bool) {
        
        if isSubject {
            rightIV.layer.borderColor = #colorLiteral(red: 0.08235294118, green: 0.5215686275, blue: 1, alpha: 1).cgColor
            rightIV.layer.borderWidth = 7
            leftIV.layer.borderColor = #colorLiteral(red: 0.08235294118, green: 0.5215686275, blue: 1, alpha: 1).cgColor
            leftIV.layer.borderWidth = 7
        } else {
            rightIV.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.1176470588, blue: 0.1568627451, alpha: 1).cgColor
            rightIV.layer.borderWidth = 7
            leftIV.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.1176470588, blue: 0.1568627451, alpha: 1).cgColor
            leftIV.layer.borderWidth = 7
        }
    }
}









