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
    int _id;
}

@property (strong, nonatomic) IBOutlet UIScrollView *container_view;
@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    _views = [NSMutableArray new];
    _id = 1;
    
    [self add_child_controller:[UIColor blueColor] text:_id++];
    [self add_child_controller:[UIColor redColor] text:_id++];
    [self add_child_controller:[UIColor greenColor] text:_id++];
    
    _container_view.delegate = self;
}

-(void)add_child_controller:(UIColor*)color text:(int)text
{
    ContentViewController* child = [[ContentViewController alloc]init_with_color:color];
    child.id_label.text = [NSString stringWithFormat:@"%d", text];
    [_views addObject:child];

    CGFloat width = [self window_width];
    self.container_view.contentSize = CGSizeMake(width * (_views.count), self.container_view.frame.size.height);

    [self.container_view addSubview:child.view];
    child.view.frame = self.container_view.bounds;
    NSLog(@"%f", child.view.frame.origin.x);
    
    CGPoint center = child.view.center;
    center.x = (_views.count - 0.5) * width ;
    child.view.center = center;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + [self window_width] / 2) / [self window_width];
    
    if (index >= _views.count - 1) {
        [self add_child_controller:[self random_color] text:_id++];
    }
}

-(UIColor*) random_color
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

    return color;
}

-(CGFloat) window_width
{
    return [[UIScreen mainScreen]bounds].size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) scroll_to_view_index:(int)index
{
    CGSize size = self.container_view.frame.size;
    CGRect rect = CGRectMake([self window_width] * index, 0, size.width, size.height);
    [self.container_view scrollRectToVisible:rect animated:YES];
}

- (IBAction)left_button_click:(id)sender
{
    [self scroll_to_view_index:0];
}

- (IBAction)middle_button_click:(id)sender {
    [self scroll_to_view_index:1];
}

- (IBAction)right_button_click:(id)sender {
    [self scroll_to_view_index:2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
