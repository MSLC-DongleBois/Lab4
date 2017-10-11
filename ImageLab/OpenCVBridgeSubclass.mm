//
//  OpenCVBridgeSubclass.m
//  ImageLab
//
//  Created by Logan Dorsey on 10/3/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

#import "OpenCVBridgeSubclass.hh"

#import "AVFoundation/AVFoundation.h"


using namespace cv;

@interface OpenCVBridgeSubclass()
@property (nonatomic) cv::Mat image;
@end

@implementation OpenCVBridgeSubclass
@dynamic image;
//@dynamic just tells the compiler that the getter and setter methods are implemented not by the class itself but somewhere else (like the superclass or will be provided at runtime).

-(int)processImage{
    
    cv::Mat image_copy;
    char text[50];
    Scalar avgPixelIntensity;
    cv::Mat image = self.image;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    avgPixelIntensity = cv::mean( image_copy );
    sprintf(text,"Avg. B: %.0f, G: %.0f, R: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(20, 100), FONT_HERSHEY_PLAIN, 0.75, Scalar::all(255), 1, 2);
    
    static int count = 0;
    const int iters = 420;
    
    int threshold = 50;
    
    static int bpm = 0;
    
    static float avgBlue[iters];
    static float avgGreen[iters];
    static float avgRed[iters];
    
    self.image = image;
    
    avgPixelIntensity = cv::mean(image_copy);
    
    // IF THE CAMERA IS COVERED
    if (avgPixelIntensity.val[2] < threshold)
    {
        if (count < iters)
        {
            avgBlue[count] = avgPixelIntensity.val[0];
            avgGreen[count] = avgPixelIntensity.val[1];
            avgRed[count] = avgPixelIntensity.val[2];
            count++;
        }
        
        sprintf(text,"Avg. B: %.0f, G: %.0f, R: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
        
        if (count == iters)
        {
            NSLog(@"BGR Arrays are filled");
            
            
            
            
            
        }
        
    }
    
    //return 0;
}

-(bool)peakFind:(float*)arrIn withIndex:(int)index
{
    
    int window = 15;
    int start = 0;
    int end = 419;
    int peakIndex = -1;
    float peak = 0.0;
    
    if (index - window > 0)
    {
        start = index - window;
    }
    
    if (index + window < 419)
    {
        end = index + window;
    }
    
    for (int i = start; i < end; i++)
    {
        if (arrIn[i] > peak)
        {
            peak = arrIn[i];
            peakIndex = i;
        }
    }
    
    if (peakIndex == index)
    {
        return true;
    }
    
    return false;
    
}

-(int)calculateBpm:(float*) redArr {
    static std::vector<int> allPeaks;
    
    for (int i = 0; i < 420; i++)
    {
        
        bool test;
        
        
        test = peakFind(redArr, i);
        if (test)
        {
            allPeaks.push_back(i);
        }
    }
    
}


@end

