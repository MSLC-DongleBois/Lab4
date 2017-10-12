//
//  ViewController.swift
//  ImageLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import AVFoundation

var statusBarIsHidden = true


class HeartViewController: UIViewController   {
    
    //MARK: Class Properties
    var filters : [CIFilter]! = nil
    var videoManager:VideoAnalgesic! = nil
    let pinchFilterIndex = 2
    var detector:CIDetector! = nil
    let bridge = OpenCVBridgeSubclass()
    var isFlashOn = false
    
    //MARK: Outlets in view
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var bpmLabel: UILabel!
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        
    }
    
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage{
        
        if !isFlashOn
        {
            self.videoManager.toggleFlash()
            isFlashOn = true
        }
        
        var retImage = inputImage

        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent, // the first face bounds
            andContext: self.videoManager.getCIContext())
        
        var bpm: Int32 = -1
        
        bpm = self.bridge.processImage()
        
       
        
        DispatchQueue.main.async() {
            if (bpm == -1)
            {
                self.instructionLabel.isHidden = false
            }
                
            else
            {
                if (bpm < 10)
                {
                    self.bpmLabel.text = "Scanning..."
                    self.instructionLabel.isHidden = true
                }
                
                else
                {
                    self.bpmLabel.text = String(bpm) + " BPM"
                }
                
            }
        }
        
  
        
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        return retImage
    }
    
   
    override func viewDidDisappear(_ animated: Bool) {
        if(self.videoManager.isRunning){
            self.videoManager.turnOffFlash()
            self.videoManager.stop()
            self.videoManager.shutdown()
        }
    }
    
    
    
    

    
    
    

  
    
    
}

