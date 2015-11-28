//
//  TabBarController.h
//  CompositeController
//
//  Created by Alex Kalinin on 11/26/15.
//  Copyright (c) 2015 Alex Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlidingContainerController_DataSource
// 0 - the initial visible controller
// +1, +2, +3, etc
// -1 -2, -3, etc.
-(UIViewController*)create_controller_for_index:(int)index;
@end

@interface SlidingContainerController : UIViewController
- (id)init_with_data_source:(id <SlidingContainerController_DataSource>)data_source;
@end
