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
    // YUHHHHHH
    var videoManager : VideoAnalgesic! = nil
    
    // filters for face, eye, mouth
    let faceFilter : CIFilter = CIFilter(name: "CITwirlDistortion")!
    let eyeFilter : CIFilter = CIFilter(name: "CIPinchDistortion")!
    let mouthFilter : CIFilter = CIFilter(name: "CIRadialGradient")!
    
    // labels & outlets
    @IBOutlet weak var leftBlink: UILabel!
    @IBOutlet weak var rightBlink: UILabel!
    @IBOutlet weak var numberOfFaces: UILabel!
    @IBOutlet weak var smileDetect: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        
        // front camera for convenience
        // can set to "AVCaptureDevice.Position.back" if desired
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processFaces)
        
        if !self.videoManager.isRunning{
            self.videoManager.start()
        }
    }

    func processFaces(inputImage:CIImage) -> CIImage{
        // setting up CIColor to use in conjunction with CIRadialGradient
        // UIColor -> CIColor
        let uiGreen : UIColor = UIColor.green
        let blank : UIColor = UIColor.clear
        let mouthColorOne : CIColor = CIColor(color: uiGreen)
        let mouthColorTwo : CIColor = CIColor(color: blank)
        self.mouthFilter.setValue(mouthColorOne, forKey: "inputColor1")
        self.mouthFilter.setValue(mouthColorTwo, forKey: "inputColor0")
        
        // from Larson's slides
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: self.videoManager.getCIContext(), options: optsDetector)
        
        // added smile & blink detection
        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.shared.statusBarOrientation), CIDetectorSmile:true, CIDetectorEyeBlink:true] as [String : Any]

        // gimme them faces BOI
        var features = detector?.features(in: inputImage, options: optsFace)
        // need variable for various coordinates
        var point = CGPoint()
        // buffer set equal to each frame
        var buffer = inputImage
        // if ZERO faces are detected
        if features?.count == 0{
            DispatchQueue.main.async{
                self.numberOfFaces.text = "No Faces Found"
                self.smileDetect.text = ""
                self.leftBlink.text = ""
                self.rightBlink.text = ""
            }
        }
        // if ONLY ONE face is detected
        else if features?.count == 1{
            let faceCount = 1
            var smile = ""
            var leftEye = ""
            var rightEye = ""
            let face : CIFaceFeature = features![0] as! CIFaceFeature
            if face.hasSmile{
                smile = "😊"
            }
            else{
                smile = "😐"
            }
            if face.leftEyeClosed{
                leftEye = "L👁: Closed"
            }
            else{
                leftEye = "L👁: Open"
            }
            if face.rightEyeClosed{
                rightEye = "R👁: Closed"
            }
            else{
                rightEye = "R👁: Open"
            }
            DispatchQueue.main.async{
                self.numberOfFaces.text = String(faceCount)
                self.smileDetect.text = smile
                self.leftBlink.text = leftEye
                self.rightBlink.text = rightEye
            }
        }
        // MULTIPLE faces are detected
        else{
            DispatchQueue.main.async{
                self.numberOfFaces.text = String(describing: features!.count)
                self.smileDetect.text = ""
                self.leftBlink.text = ""
                self.rightBlink.text = ""
            }
        }
        
        for face in features as! [CIFaceFeature]{
            // height of face
            let height = face.bounds.size.height
            // set x, y values for middle of FACE
            point.x = face.bounds.midX
            point.y = face.bounds.midY
            // image from camera
            self.faceFilter.setValue(buffer, forKey: "inputImage")
            // center of face
            self.faceFilter.setValue(CIVector(x: point.x, y:point.y), forKey: "inputCenter")
            // half of face height
            self.faceFilter.setValue(height/2, forKey: "inputRadius")
            // amount of twirl
            self.faceFilter.setValue(0.7, forKey: "inputAngle")
            let combineFilter : CIFilter = CIFilter(name: "CISourceOverCompositing")!
            // combine & set to buffer
            combineFilter.setValue(self.faceFilter.outputImage, forKey: "inputImage")
            combineFilter.setValue(buffer, forKey: "inputBackgroundImage")
            buffer = combineFilter.outputImage!
            
            if face.hasLeftEyePosition{
                // set new x, y values for LEFT EYE
                point.x = face.leftEyePosition.x
                point.y = face.leftEyePosition.y
                // image from camera
                self.eyeFilter.setValue(buffer, forKey: "inputImage")
                // x, y values for left eye
                self.eyeFilter.setValue(CIVector(x: point.x, y:point.y), forKey: "inputCenter")
                // radius value for distortion
                self.eyeFilter.setValue(150, forKey: "inputRadius")
                // scale value for distortion
                self.eyeFilter.setValue(0.25, forKey: "inputScale")
                // combine & set to buffer
                combineFilter.setValue(self.eyeFilter.outputImage, forKey: "inputImage")
                combineFilter.setValue(buffer, forKey: "inputBackgroundImage")
                buffer = combineFilter.outputImage!
            }
            
            if face.hasRightEyePosition{
                // set new x, y values for RIGHT EYE
                point.x = face.rightEyePosition.x
                point.y = face.rightEyePosition.y
                // image from camera
                self.eyeFilter.setValue(buffer, forKey: "inputImage")
                // x, y values for left eye
                self.eyeFilter.setValue(CIVector(x: point.x, y:point.y), forKey: "inputCenter")
                // radius value for distortion
                self.eyeFilter.setValue(150, forKey: "inputRadius")
                // scale value for distortion
                self.eyeFilter.setValue(0.25, forKey: "inputScale")
                // combine & set to buffer
                combineFilter.setValue(self.eyeFilter.outputImage, forKey: "inputImage")
                combineFilter.setValue(buffer, forKey: "inputBackgroundImage")
                buffer = combineFilter.outputImage!
            }
            
            if face.hasMouthPosition{
                point.x = face.mouthPosition.x
                point.y = face.mouthPosition.y
                self.mouthFilter.setValue(CIVector(x: point.x, y:point.y), forKey: "inputCenter")
                self.mouthFilter.setValue(height/7, forKey: "inputRadius0")
                self.mouthFilter.setValue(height/7 - 20, forKey: "inputRadius1")
                combineFilter.setValue(self.mouthFilter.outputImage, forKey: "inputImage")
                combineFilter.setValue(buffer, forKey: "inputBackgroundImage")
                buffer = combineFilter.outputImage!
            }
            
        }
        return buffer
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(self.videoManager.isRunning){
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
}
