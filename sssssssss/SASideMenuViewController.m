//
//  SASideMenuViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 13.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SASideMenuViewController.h"
#import "SAAppDelegate.h"

#define statusbarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define viewWidth self.view.frame.size.width
#define viewHeight self.view.frame.size.height
#define viewOriginX self.view.frame.origin.x
#define viewOriginY self.view.frame.origin.y

#define insetLeft 100
#define insetRight 200
#define scaleFactor 0.9

#define sideMenuHiddenCenter CGPointMake(viewWidth/2, viewHeight/2)
#define sideMenuShowingCenter CGPointMake(viewWidth/2 + insetRight, viewHeight/2)

#define sideMenuShowingFrame CGRectMake(viewWidth -insetLeft , statusbarHeight + sizeReductionY/2 , viewWidth, viewHeight -(statusbarHeight + sizeReductionY))

#define sideMenuHiddenFrame CGRectMake(viewOriginX, viewOriginY + statusbarHeight, viewWidth, viewHeight -statusbarHeight)

@interface SASideMenuViewController ()
@property(nonatomic,strong) NSArray *options;
@property(nonatomic,strong) NSArray *segueIdentifiers;
@property(nonatomic, strong) UITapGestureRecognizer *tap;
@property CGAffineTransform originalTransform;

@end

@implementation SASideMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"denoiwefiowejfoewjow");
    
    
    
    _options = [NSArray arrayWithObjects:@"Suche",@"Merkliste",@"Account", nil];
    _segueIdentifiers = [NSArray arrayWithObjects:@"showSearch",@"showWatchlist",@"showAccount", nil];
    
    _currentView = _currentViewController.view;
    _currentView.userInteractionEnabled = NO;
    
    _nextViewController = _currentViewController;
    _nextView = _currentView;
    
    self.containerView = [[UIView alloc] initWithFrame: self.view.frame];
    _originalTransform = self.containerView.transform;
    
    [self.view addSubview:_containerView];
    _containerView.clipsToBounds=NO;
    
    [self.containerView addSubview:_currentView];
    //self.containerView.contentMode= UIViewContentModeScaleAspectFit;
    //_currentView.contentMode=UIViewContentModeScaleAspectFit;
    
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideMenu)];
    
    [_containerView addGestureRecognizer:_tap];
    
    _containerView.autoresizesSubviews=YES;
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    
    
    //self.view.backgroundColor = [UIColor redColor];
	// Do any additional setup after loading the view.
}

-(void)hideSideMenuAndChangeViewController:(NSString *)viewController
{
    if([viewController isEqualToString:_activeViewControllerIdentifier])
    {
        _nextViewController = _currentViewController;
        _nextView = _currentView;
        

    }
    else if([viewController isEqualToString:@"Merkliste"]){
       _nextViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Merkliste"];
        
        _nextView = _nextViewController.view;
        [_currentView removeFromSuperview];
        [_containerView addSubview:_nextView];
        
        
    }
    else if([viewController isEqualToString:@"Suche"]){
        _nextViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Suche"];
        
        _nextView = _nextViewController.view;
        [_currentView removeFromSuperview];
        [_containerView addSubview:_nextView];
    }
    else if([viewController isEqualToString:@"Account"]){
        _nextViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Account"];
        
        _nextView = _nextViewController.view;
        [_currentView removeFromSuperview];
        [_containerView addSubview:_nextView];
    }

    self.activeViewControllerIdentifier=viewController;
    [self hideSideMenu];
}

- (void)viewDidAppear:(BOOL)animated
{
   // NSLog(@"x: %f, y: %f", self.containerView.center.x,self.containerView.center.y);
    [UIView animateWithDuration:0.2 animations:^{
        //_containerView.frame = sideMenuShowingFrame;
        _containerView.transform = self.containerView.transform = CGAffineTransformScale(_originalTransform, scaleFactor, scaleFactor);
        _containerView.center = sideMenuShowingCenter;
    } completion:nil];
}


-(void)hideSideMenu
{
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.contentViewController = _nextViewController;
    _nextView.userInteractionEnabled=YES;
    _containerView.userInteractionEnabled=NO;
   
    
    [UIView animateWithDuration:0.2 animations:^{
        //_containerView.frame = sideMenuHiddenFrame;
        _containerView.transform = self.containerView.transform = CGAffineTransformScale(_originalTransform, 1, 1);
        _containerView.center = sideMenuHiddenCenter;
    }
    completion:^(BOOL complete){
        if(complete){
             [_nextView removeFromSuperview];
            _nextViewController.view=_nextView;
            SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate hideSideMenu ];
        }
        else{
            
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _options.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text=[_options objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hideSideMenuAndChangeViewController:[_options objectAtIndex:indexPath.row]];
}




@end
