#import "SlidingContainerController.h"
#import "ContentViewController.h"
#import <objc/runtime.h>

static char controller_index_key = 0;

@interface SlidingContainerController()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *today_button;

@property (strong, nonatomic) IBOutlet UIScrollView *container_view;

@end
//----------------------------------------------------------------------------------------
@implementation SlidingContainerController
{
    NSMutableArray*_controllers;
    id <SlidingContainerController_DataSource> _data_source;
}
//----------------------------------------------------------------------------------------
-(id)init_with_data_source:(id<SlidingContainerController_DataSource>)data_source
{
    _controllers = [NSMutableArray new];
    _data_source = data_source;
    return [super init];
}
//----------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    _container_view.delegate = self;
    
    for (int index = -1; index <= 1; index++) {
        UIViewController *c = [_data_source create_controller_for_index:index];
        [self add_child_controller:c at_end:YES truncate:NO with_index:index];
    }

    [self scroll_to_view_index:1];

    self.today_button.backgroundColor = [self controller_for_index:0].view.backgroundColor;
}
//----------------------------------------------------------------------------------------
-(void)add_child_controller:(UIViewController *)child at_end:(BOOL)at_end truncate:(BOOL)truncate with_index:(int)index
{
    objc_setAssociatedObject(child, &controller_index_key, @(index), OBJC_ASSOCIATION_RETAIN);

    CGFloat width = [self window_width];

    [self.container_view addSubview:child.view];
    child.view.frame = self.container_view.bounds;
    NSLog(@"%f", child.view.frame.origin.x);
    
    CGPoint center = child.view.center;

    ContentViewController* to_remove = nil;
    
    if (at_end) {
        [_controllers addObject:child];
        center.x = (_controllers.count - 0.5f) * width;
        if (truncate) to_remove = _controllers[0];
    }
    else {
        [_controllers insertObject:child atIndex:0];
        // 1) Shift all views to the right
        // 2) Change the offset to keep the right view
        for (ContentViewController *c in _controllers) {
            if (c != child) {
                CGPoint cur_center = c.view.center;
                cur_center.x += width;
                c.view.center = cur_center;
            }
        }
        CGPoint offset = self.container_view.contentOffset;
        offset.x += width;
        self.container_view.contentOffset = offset;
        
        center.x = 0.5f * width;
        if (truncate) to_remove = _controllers[_controllers.count - 1];
    }
    
    if (to_remove) {
        [to_remove.view removeFromSuperview];
        [_controllers removeObject:to_remove];
    }
    
    self.container_view.contentSize = CGSizeMake(width * (_controllers.count), self.container_view.frame.size.height);

    child.view.center = center;
}
//----------------------------------------------------------------------------------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    unsigned int index = (unsigned int) ((scrollView.contentOffset.x + [self window_width] / 2) / [self window_width]);
    ContentViewController* current = _controllers[index];
    NSNumber* new_controller_index_offset = nil;
    
    if (index >= _controllers.count - 1) {
        new_controller_index_offset = @(1);
    }
    else if (index < 1) {
        new_controller_index_offset = @(-1);
    }
    
    if (new_controller_index_offset) {
        int new_index = [self get_index_tag:current] + [new_controller_index_offset intValue];
        UIViewController* new_controller = [_data_source create_controller_for_index:new_index];
        BOOL at_end = [new_controller_index_offset intValue] > 0;
        [self add_child_controller:new_controller at_end:at_end truncate:NO with_index:new_index];
    }
}
//----------------------------------------------------------------------------------------
-(int)get_index_tag:(UIViewController *)controller
{
    NSNumber* current_index = objc_getAssociatedObject(controller, &controller_index_key);
    return [current_index intValue];
}
//----------------------------------------------------------------------------------------
-(UIViewController*) controller_for_index:(int)target_index
{
    UIViewController *result = nil;

    for (UIViewController *c in _controllers)
    {
        int index = [self get_index_tag:c];
        if (index == target_index) {
            result = c;
            break;
        }
    }
    return result;
}
//----------------------------------------------------------------------------------------
-(int) view_index_for_index:(int)target_index
{
    int result = -1;
    int view_index = -1;
    for (UIViewController *c in _controllers)
    {
        view_index += 1;
        int index = [self get_index_tag:c];
        if (index == target_index) {
            result = view_index;
            break;
        }
    }
    return result;
}
//----------------------------------------------------------------------------------------
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
//----------------------------------------------------------------------------------------
-(CGFloat) window_width
{
    return [[UIScreen mainScreen]bounds].size.width;
}
//----------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//----------------------------------------------------------------------------------------
-(void) scroll_to_view_index:(int)index
{
    CGSize size = self.container_view.frame.size;
    CGRect rect = CGRectMake([self window_width] * index, 0, size.width, size.height);
    [self.container_view scrollRectToVisible:rect animated:YES];
}
//----------------------------------------------------------------------------------------
- (IBAction)middle_button_click:(id)sender
{
    int view_index = [self view_index_for_index:0];

    if (view_index >= 0)
        [self scroll_to_view_index:view_index];
}

@end
