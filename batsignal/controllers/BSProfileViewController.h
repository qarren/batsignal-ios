//
//  BSProfileViewController.h
//  batsignal
//
//  Created by Kyle Warren on 4/30/13.
//  Copyright (c) 2013 Kyle Warren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSProfileView;

@interface BSProfileViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, readonly) BSProfileView *profileView;

@end
