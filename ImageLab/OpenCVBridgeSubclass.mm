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

bool peakFind(float* arrIn, int index)
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

int calculateBpm(float* redArr)
{
    static std::vector<int> allPeaks;
    static std::vector<int> peakDistances;
    
    for (int i = 0; i < 420; i++)
    {
        bool test;
        
        test = peakFind(redArr, i);
        
        if (test)
        {
            allPeaks.push_back(i);
            //std::cout << i << " ";
        }
    }
    
    std::cout << std::endl;

    
    for (int i = 0; i < allPeaks.size()-2; i++)
    {
        peakDistances.push_back(allPeaks[i + 1] - allPeaks[i]);
        //std::cout << allPeaks[i + 1] - allPeaks[i] << " ";
    }
    
    int peakSums = 0;
    int numNegs = 0;
    
    for (int i = 0; i < peakDistances.size(); i++)
    {
        if (peakDistances[i] > 1)
        {
            peakSums += peakDistances[i];
           
        }
        else {
            numNegs++;
        }
    }
    
    int peakAvg = (peakSums / (peakDistances.size() - numNegs));
    
    //std::cout << peakAvg << std::endl;
    
    float heartBeatDongleConverter = 2.7777;
    int convertedBpm = (int)((float)peakAvg * heartBeatDongleConverter);
    
    std::cout << "BPM: " << convertedBpm << std::endl;
    
    return convertedBpm;
}

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
    
    int threshold = 55;
    
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
            bpm = calculateBpm(avgRed);
            count = 0;
        }
        
    }
    
    else
    {
        return -1;
    }
    
    //return 0;
    return bpm;
}


@end

