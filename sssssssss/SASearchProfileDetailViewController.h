//
//  SASearchProfileDetailViewController.h
//  FaboTest
//
//  Created by Simon Anreiter on 19.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CDSearchProfile;


@protocol SASearchProfileDetailViewControllerDelegate <NSObject>
@required
-(void)saveNewSearchProfile:(CDSearchProfile *)searchProfile;
-(void)updateSearchProfile;
-(void)deleteSearchProfile:(CDSearchProfile *)searchProfile;
@end



@interface SASearchProfileDetailViewController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, assign) id delegate;

@property BOOL editingMode;
@property CDSearchProfile *searchProfile;


@end
