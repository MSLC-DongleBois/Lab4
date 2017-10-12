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
        // UIColor -> CIColor
        let uiRed : UIColor = UIColor.red
        let uiBlue : UIColor = UIColor.blue
        let uiGreen : UIColor = UIColor.green
        let faceColor : CIColor = CIColor(color: uiRed)
        let eyeColor : CIColor = CIColor(color: uiBlue)
        let mouthColor : CIColor = CIColor(color: uiGreen)
        self.faceFilter.setValue(faceColor, forKey: "inputColor1")
        self.eyeFilter.setValue(eyeColor, forKey: "inputColor1")
        self.mouthFilter.setValue(mouthColor, forKey: "inputColor1")
        
        // from Larson's slides
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: self.videoManager.getCIContext(), options: optsDetector)
        // added smile & blink detection
        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.shared.statusBarOrientation), CIDetectorSmile:true, CIDetectorEyeBlink:true] as [String : Any]
        self.videoManager.setProcessingBlock(newProcessBlock: {(inputImage:CIImage)->(CIImage) in
            var features = detector?.features(in: inputImage, options: optsFace)
            var swap = CGPoint()
            var buffer = inputImage
            
            // if no faces detected
            if features?.count == 0{
                DispatchQueue.main.async{
                    self.numberOfFaces.text = "No Faces Found"
                }
            }
            else if features?.count == 1{
                let face : CIFaceFeature = features![0] as! CIFaceFeature
                var faceDetails = ""
                if face.hasSmile{
                    faceDetails += "Smile "
                }
                else{
                    faceDetails += "No Smile "
                }
                if face.leftEyeClosed{
                    faceDetails += "Left Eye Closed "
                }
                else{
                    faceDetails += "Left Eye Open "
                }
                if face.rightEyeClosed{
                    faceDetails += "Right Eye Closed"
                }
                else{
                    faceDetails += "Right Eye Open"
                }
                DispatchQueue.main.async{
                    self.numberOfFaces.text = faceDetails
                }
            }
            else{
                DispatchQueue.main.async{
                    let count = features?.count
                    self.numberOfFaces.text = "\(count)"
                }
            }
            for face in features as! [CIFaceFeature]{
                
            }
            return buffer
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
