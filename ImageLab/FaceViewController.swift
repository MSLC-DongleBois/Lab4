//
//  FaceViewController.swift
//  ImageLab
//
//  Created by Kevin Queenan on 10/12/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

class FaceViewController: UIViewController {
    var videoManager : VideoAnalgesic! = nil
    
    let faceFilter : CIFilter = CIFilter(name: "CISmoothLinearGradient")!
    let eyeFilter : CIFilter = CIFilter(name: "CISmoothLinearGradient")!
    let mouthFilter : CIFilter = CIFilter(name: "CISmoothLinearGradient")!
    
    @IBOutlet weak var numberOfFaces: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        
        // setting up CIColors to use in conjunction with CIFilters
        let uiRed : UIColor = UIColor.red
        let uiBlue : UIColor = UIColor.blue
        let uiGreen : UIColor = UIColor.green
        let faceColor : CIColor = CIColor(color: uiRed)
        let eyeColor : CIColor = CIColor(color: uiBlue)
        let mouthColor : CIColor = CIColor(color: uiGreen)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
