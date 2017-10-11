//
//  OpenCVBridgeSubclass.h
//  ImageLab
//
//  Created by Logan Dorsey on 10/3/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

#import "OpenCVBridge.hh"

@interface OpenCVBridgeSubclass : OpenCVBridge
bool peakFind(float*,int);
int calculateBpm(float*);
@end
