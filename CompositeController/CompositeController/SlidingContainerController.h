#import <UIKit/UIKit.h>

@protocol SlidingContainerController_DataSource
// 0 - the initial visible controller
// +1, +2, +3, etc
// -1, -2, -3, etc.
-(UIViewController*)create_controller_for_index:(int)index;
@end

@interface SlidingContainerController : UIViewController
- (id)init_with_data_source:(id <SlidingContainerController_DataSource>)data_source;
@end
