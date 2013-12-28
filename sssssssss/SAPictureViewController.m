//
//  SAPictureViewController.m
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 22.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import "SAPictureViewController.h"

#define VIEW_FOR_ZOOM_TAG (1)



@interface SAPictureViewController ()


@property(nonatomic, strong) NSMutableArray *images;
@property NSUInteger activePage;

@end



@implementation SAPictureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setImages:(NSMutableArray *)images ActivePage:(NSUInteger)activePage
{
    _images = images;
    _activePage = activePage;
    
    //[self configureView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        [self configureView];
    
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{

}

-(void)configureView
{
    //self.view.frame = CGRectMake(0, 0, 320, 480);
    //self.view.backgroundColor = [UIColor whiteColor];
    _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    //NSLog(@"x:%f\ny: %f\n h: %f\nw: %f", mainScrollView.frame.origin.x, mainScrollView.frame.origin.y, mainScrollView.frame.size.height, mainScrollView.frame.size.width);
    
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    //mainScrollView.backgroundColor = [UIColor lightGrayColor];
    
    CGRect innerScrollFrame = _mainScrollView.bounds;
    
    for (NSInteger i = 0; i < _images.count; i++) {
        UIImageView *imageForZooming = [[UIImageView alloc] initWithImage:[_images objectAtIndex:i]];
        imageForZooming.contentMode = UIViewContentModeScaleAspectFit;
        //CGFloat aspect = imageForZooming.frame.size.height / imageForZooming.frame.size.width;
        //imageForZooming.bounds = _mainScrollView.bounds;
        imageForZooming.tag = VIEW_FOR_ZOOM_TAG;
        imageForZooming.center = CGPointMake(innerScrollFrame.size.width * 0.5,
                                             innerScrollFrame.size.height * 0.5);
        
        UIScrollView *pageScrollView = [[UIScrollView alloc] initWithFrame:innerScrollFrame];
        float minimumScale = [pageScrollView frame].size.width  / [imageForZooming frame].size.width;
        pageScrollView.minimumZoomScale = minimumScale;
        pageScrollView.maximumZoomScale = 2.0f;
        
        
        
        pageScrollView.contentSize = innerScrollFrame.size;
        pageScrollView.delegate = self;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        [pageScrollView addSubview:imageForZooming];
        pageScrollView.zoomScale = minimumScale;
        

        
        //pageScrollView.contentOffset.x = newContentOffsetX;
        
        [_mainScrollView addSubview:pageScrollView];
        
        if (i < _images.count-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
    }
    
    _mainScrollView.contentSize = CGSizeMake(innerScrollFrame.origin.x +
                                            innerScrollFrame.size.width, _mainScrollView.bounds.size.height);
    
    [self.view addSubview:_mainScrollView];
    
    [_mainScrollView setContentOffset:CGPointMake(320*_activePage, 0)];

    
    //UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBars)];
    
    //[_mainScrollView addGestureRecognizer:singleTap];

    
    //self.parentViewController.

}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"Content offset x:%f y:%f",self.scrollView.contentOffset.x,self.scrollView.contentOffset.y);
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

-(UIView *)newPlaceHolderWithFrame:(CGRect)frame
{
    UIView *placeHolder = [[UIView alloc] initWithFrame:frame];
    //placeHolder.backgroundColor = [UIColor lightGrayColor];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect avFrame = CGRectMake((frame.size.width - 25)/2.0,(frame.size.height - 25)/2.0, 25, 25);
    activityIndicator.frame = avFrame;
    [placeHolder addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    return placeHolder;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
