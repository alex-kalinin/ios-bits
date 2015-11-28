#import "SlidingContainerController.h"
#import "ContentViewController.h"
#import <objc/runtime.h>

static char controller_index_key = 0;

@interface SlidingContainerController()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *container_view;

@end
//----------------------------------------------------------------------------------------
@implementation SlidingContainerController
{
    NSMutableArray* _views;
    id <SlidingContainerController_DataSource> _data_source;
}
//----------------------------------------------------------------------------------------
-(id)init_with_data_source:(id<SlidingContainerController_DataSource>)data_source
{
    _views = [NSMutableArray new];
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
        [_views addObject:child];
        center.x = (_views.count - 0.5f) * width;
        if (truncate) to_remove = _views[0];
    }
    else {
        [_views insertObject:child atIndex:0];
        // 1) Shift all views to the right
        // 2) Change the offset to keep the right view
        for (ContentViewController *c in _views) {
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
        if (truncate) to_remove = _views[_views.count - 1];
    }
    
    if (to_remove) {
        [to_remove.view removeFromSuperview];
        [_views removeObject:to_remove];
    }
    
    self.container_view.contentSize = CGSizeMake(width * (_views.count), self.container_view.frame.size.height);

    child.view.center = center;
}
//----------------------------------------------------------------------------------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    unsigned int index = (unsigned int) ((scrollView.contentOffset.x + [self window_width] / 2) / [self window_width]);
    ContentViewController* current = _views[index];
    NSNumber* new_controller_index_offset = nil;
    
    if (index >= _views.count - 1) {
        new_controller_index_offset = @(1);
    }
    else if (index < 1) {
        new_controller_index_offset = @(-1);
    }
    
    if (new_controller_index_offset) {
        NSNumber* current_index = objc_getAssociatedObject(current, &controller_index_key);
        int new_index = [current_index intValue] + [new_controller_index_offset intValue];
        UIViewController* new_controller = [_data_source create_controller_for_index:new_index];
        BOOL at_end = [new_controller_index_offset intValue] > 0;
        [self add_child_controller:new_controller at_end:at_end truncate:NO with_index:new_index];
    }
}
//----------------------------------------------------------------------------------------
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    int index = (int) (scrollView.contentOffset.x / [self window_width]);
}
//----------------------------------------------------------------------------------------
-(CGFloat) window_width
{
    return [[UIScreen mainScreen]bounds].size.width;
}
//----------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//----------------------------------------------------------------------------------------
-(void) scroll_to_view_index:(int)index
{
    CGSize size = self.container_view.frame.size;
    CGRect rect = CGRectMake([self window_width] * index, 0, size.width, size.height);
    [self.container_view scrollRectToVisible:rect animated:YES];
}
//----------------------------------------------------------------------------------------
- (IBAction)left_button_click:(id)sender
{
    [self scroll_to_view_index:0];
}
//----------------------------------------------------------------------------------------
- (IBAction)middle_button_click:(id)sender {
    [self scroll_to_view_index:1];
}
//----------------------------------------------------------------------------------------
- (IBAction)right_button_click:(id)sender {
    [self scroll_to_view_index:2];
}

@end
