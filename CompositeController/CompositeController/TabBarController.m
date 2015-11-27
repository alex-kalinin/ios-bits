//
//  TabBarController.m
//  CompositeController
//
//  Created by Alex Kalinin on 11/26/15.
//  Copyright (c) 2015 Alex Kalinin. All rights reserved.
//

#import "TabBarController.h"
#import "ContentViewController.h"

@interface TabBarController()<UIScrollViewDelegate>
{
    NSMutableArray* _views;
    ContentViewController* _displaying;
//    int _id;
}

@property (strong, nonatomic) IBOutlet UIScrollView *container_view;
@end

@implementation TabBarController
//------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];

    _views = [NSMutableArray new];
    int _id = 1;
    
    [self add_child_controller:[UIColor blueColor] text:_id++ at_end:YES truncate:NO];
    [self add_child_controller:[UIColor redColor] text:_id++ at_end:YES truncate:NO];
    [self add_child_controller:[UIColor greenColor] text:_id++ at_end:YES truncate:NO];
    
    [self scroll_to_view_index:1];
    
    _container_view.delegate = self;
}
//------------------------------------------------------------------------------
-(void)add_child_controller:(UIColor*)color text:(int)text at_end:(BOOL)at_end truncate:(BOOL)truncate
{
    ContentViewController* child = [[ContentViewController alloc]init_with_color:color];
    child.id_label.text = [NSString stringWithFormat:@"%d", text];
    child.id_int = text;

    CGFloat width = [self window_width];

    [self.container_view addSubview:child.view];
    child.view.frame = self.container_view.bounds;
    NSLog(@"%f", child.view.frame.origin.x);
    
    CGPoint center = child.view.center;

    ContentViewController* to_remove = nil;
    
    if (at_end) {
        [_views addObject:child];
        center.x = (_views.count - 0.5) * width;
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
        
        center.x = 0.5 * width;
        if (truncate) to_remove = _views[_views.count - 1];
    }
    
    if (to_remove) {
        [to_remove.view removeFromSuperview];
        [_views removeObject:to_remove];
    }
    
    self.container_view.contentSize = CGSizeMake(width * (_views.count), self.container_view.frame.size.height);

    child.view.center = center;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + [self window_width] / 2) / [self window_width];
    ContentViewController* current = _views[index];
    
    if (index >= _views.count - 1) {
        // Add a new controller at the end, remove at the head
        [self add_child_controller:[self random_color] text:current.id_int + 1 at_end:YES truncate:NO];
    }
    else if (index < 1) {
        // Add at the head, remove at the end
        [self add_child_controller:[self random_color] text:current.id_int - 1 at_end:NO truncate:NO];
    }
}
//------------------------------------------------------------------------------
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / [self window_width];
}
//------------------------------------------------------------------------------
-(UIColor*) random_color
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

    return color;
}
//------------------------------------------------------------------------------
-(CGFloat) window_width
{
    return [[UIScreen mainScreen]bounds].size.width;
}
//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//------------------------------------------------------------------------------
-(void) scroll_to_view_index:(int)index
{
    CGSize size = self.container_view.frame.size;
    CGRect rect = CGRectMake([self window_width] * index, 0, size.width, size.height);
    [self.container_view scrollRectToVisible:rect animated:YES];
}
//------------------------------------------------------------------------------
- (IBAction)left_button_click:(id)sender
{
    [self scroll_to_view_index:0];
}
//------------------------------------------------------------------------------
- (IBAction)middle_button_click:(id)sender {
    [self scroll_to_view_index:1];
}
//------------------------------------------------------------------------------
- (IBAction)right_button_click:(id)sender {
    [self scroll_to_view_index:2];
}

@end
