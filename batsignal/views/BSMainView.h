//
//  BSMainView.h
//  batsignal
//
//  Created by Kyle Warren on 4/29/13.
//  Copyright (c) 2013 Kyle Warren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BSMainView : UIView

@property (nonatomic, readonly) MKMapView *mapView;
@property (nonatomic, readonly) UIButton *postSignalButton;

@end
