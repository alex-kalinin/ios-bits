//
//  ContextViewController.h
//  CompositeController
//
//  Created by Alex Kalinin on 11/26/15.
//  Copyright (c) 2015 Alex Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *id_label;
-(id)init_with_color:(UIColor*)color;
@end
