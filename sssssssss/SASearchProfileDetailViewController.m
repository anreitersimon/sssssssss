//
//  SASearchProfileDetailViewController.m
//  FaboTest
//
//  Created by Simon Anreiter on 19.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SASearchProfileDetailViewController.h"
#import "CDSearchProfile.h"

#define kDateStartRow   1
#define kDateEndRow     2

#define kTextFieldTag 3
#define kLabelTag 2
#define kDeleteButtonTag 5
#define kDetailTag 6

#define kMietenTag 10
#define kKaufenTag 11

#define kStandardCellHeight 44

static NSString *kOtherCell = @"otherCell";
static NSString *kStandardCell = @"standardCell";
static NSString *kShowCategoryCellID = @"showCategoryCell";
static NSString *kCategoryCellID = @"categoryCell";
static NSString *kDeleteCell = @"deleteCell";
static NSString *kTypeCell = @"typeCell";
static NSString *kEntryCell = @"entryCell";

static NSString *kTitleKey = @"title";
static NSString *kPlaceholderKey = @"placeholder";
static NSString *kDetailKey = @"detail";

static NSString *kSelectionMietenKey = @"Mieten";
static NSString *kSelectionKaufenKey = @"Kaufen";
static NSString *kSelectionNoneKey = @"None";

static NSString *googleAPIKey = @"AIzaSyBMwhP4BQDQK7upUVNNQjC5dKREicl-a-Q";

static NSString *googleAtuoComplete = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&sensor=true&types=(cities)&language=pt_BR&key=%@";

@interface SASearchProfileDetailViewController ()

@property BOOL showCategories;

@property(nonatomic,strong) NSIndexPath *indexPathForShowCategoryCell;

@property(nonatomic, weak) UITextField *activeTextField;

@property(nonatomic,strong) NSArray *sectionOneData;
@property(nonatomic,strong) NSArray *sectionTwoData;
@property(nonatomic,strong) NSArray *sectionThreeData;
@property(nonatomic,strong) NSArray *sectionFourData;

@property(nonatomic, strong) NSArray *immoTypeKaufen;
@property(nonatomic, strong) NSArray *immoTypeMieten;

@property(nonatomic, weak) UITextField *locationField;
@property(nonatomic, weak) UITextField *priceField;
@property(nonatomic, weak) UITextField *roomsField;
@property(nonatomic, weak) UITextField *sizeField;
@property(nonatomic, weak) UIButton *deleteButton;

@property(nonatomic, strong) IBOutlet UIButton *mietenTypeButton;
@property(nonatomic, strong) IBOutlet UIButton *kaufenTypeButton;
@property(nonatomic, strong)  UIButton *lastSelectedTypeButton;

@property(nonatomic, strong) NSArray *categoryList;
@property(nonatomic, strong) NSString *selectedType;


@property(nonatomic, strong) NSIndexPath *indexPathForSelectedType;
@property(nonatomic, strong) NSIndexPath *indexPathForSelectedMietenCategory;
@property(nonatomic, strong) NSIndexPath *indexPathForSelectedKaufenCategory;


@end

@implementation SASearchProfileDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(saveChanges)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismissModalViewControllerAnimated:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    _selectedType = kSelectionNoneKey;
    
    _immoTypeKaufen = [NSArray arrayWithObjects: @"Eigentumswohnung",@"Eigentumshaus",@"Baugrund",@"Bürofläche", nil];
    _immoTypeMieten = [NSArray arrayWithObjects:@"Mietwohnung",@"Miethaus", @"WG-Zimmer", @"Proberaum", @"Garage-Stellplatz",@"Bürofläche", nil];
    

    NSMutableDictionary *itemOne = [@{ kPlaceholderKey : @"Location" } mutableCopy];
    
    
    
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"Preis", kPlaceholderKey : @"bis" } mutableCopy];
    NSMutableDictionary *itemFive = [@{ kTitleKey : @"Räume", kPlaceholderKey : @"ab" } mutableCopy];
    NSMutableDictionary *itemSix = [@{ kTitleKey : @"Größe", kPlaceholderKey : @"ab" }  mutableCopy];
    
    NSMutableDictionary *itemSeven= [@{ kTitleKey : @"Typ", kDetailKey : @"" }  mutableCopy];
    
    
    self.sectionOneData = @[itemOne];
    
    _categoryList = @[];

    self.sectionThreeData = @[itemSeven, _categoryList];
    self.sectionFourData = @[itemFour, itemFive, itemSix];

    
    //[self.tableView addGestureRecognizer:tap];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) hasSelectedType
{
    return _selectedType!=kSelectionNoneKey;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_editingMode ? 5 : 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return _sectionOneData.count;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return (_showCategories && [self hasSelectedType]? 1 + [_categoryList count] : 1);
            break;
            
        case 3:
            return _sectionFourData.count;
            break;
            
        case 4:
            return 1;
            break;
            
            
        default:
            return 0;
            break;
    }

}


-(void)didSelectType:(UIButton *)sender
{
    [self dismissKeyboard];
    if(_selectedType==kSelectionKaufenKey && sender==_kaufenTypeButton)
    {
        _selectedType = kSelectionNoneKey;
        _categoryList = @[];
        _showCategories = NO;
    }
    
    else if(_selectedType==kSelectionMietenKey && sender==_mietenTypeButton)
    {
        _selectedType = kSelectionNoneKey;
        _categoryList = @[];
        _showCategories = NO;
    }
    
    else if(_selectedType!=kSelectionMietenKey && sender==_mietenTypeButton)
    {
        _selectedType = kSelectionMietenKey;
        _categoryList = _immoTypeMieten;
    }

    else if(_selectedType!=kSelectionKaufenKey && sender==_kaufenTypeButton)
    {
        _selectedType = kSelectionKaufenKey;
        _categoryList = _immoTypeKaufen;
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];

    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=nil;
    
    if(indexPath.section==0 && indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kStandardCell forIndexPath:indexPath];
        
        UITextField *textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
        _locationField = textField;
        textField.delegate = self;
        NSDictionary *data = [self.sectionOneData objectAtIndex:indexPath.row];
        textField.placeholder = [data objectForKey:kPlaceholderKey];
    }
    
    if(indexPath.section==1)
    {

            cell = [tableView dequeueReusableCellWithIdentifier:kTypeCell forIndexPath:indexPath];
            _mietenTypeButton = (UIButton *)[cell viewWithTag:kMietenTag];
            _kaufenTypeButton = (UIButton *)[cell viewWithTag:kKaufenTag];
            
            [_mietenTypeButton addTarget:self action:@selector(didSelectType:) forControlEvents:UIControlEventTouchUpInside];
            [_kaufenTypeButton addTarget:self action:@selector(didSelectType:) forControlEvents:UIControlEventTouchUpInside];
            
             [_mietenTypeButton setBackgroundColor:[UIColor whiteColor]];
             [_kaufenTypeButton setBackgroundColor:[UIColor whiteColor]];
            if(_selectedType == kSelectionMietenKey)
                [_mietenTypeButton setBackgroundColor:[UIColor greenColor]];
            if(_selectedType == kSelectionKaufenKey)
                [_kaufenTypeButton setBackgroundColor:[UIColor greenColor]];

    }
    
    if(indexPath.section==2)
    {
        if(indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kShowCategoryCellID forIndexPath:indexPath];
            _indexPathForShowCategoryCell = indexPath;
            UILabel *detailLabel = (UILabel *)[cell viewWithTag:kDetailTag];
            detailLabel.text = [self selectedCategory];
        }
        
        if(indexPath.row!=0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellID forIndexPath:indexPath];
            
            UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
            
            label.text = [_categoryList objectAtIndex:indexPath.row-1];
            
            if(_selectedType == kSelectionKaufenKey)
            {
                if([indexPath isEqual:_indexPathForSelectedKaufenCategory])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            if(_selectedType == kSelectionMietenKey)
            {
                if([indexPath isEqual:_indexPathForSelectedMietenCategory])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    if(indexPath.section==3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kEntryCell forIndexPath:indexPath];
        NSLog(@"dfsgsdgsd");
        UITextField *textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
        UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
        UILabel *unitLabel = (UILabel *)[cell viewWithTag:kDetailTag];
        
        if(indexPath.row == 0)
        {
            _priceField = textField;
            unitLabel.text = @"€";
        }
        else if(indexPath.row == 1)
        {
            _roomsField = textField;
            unitLabel.text = @"Z.";
        }
        else if(indexPath.row == 2)
        {
            _sizeField = textField;
            unitLabel.text = @"m²";
        }
        
        NSDictionary *data = [self.sectionFourData objectAtIndex:indexPath.row];
        
        textField.placeholder = [data objectForKey:kPlaceholderKey];
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        label.text = [data objectForKey:kTitleKey];
    }

    
    if(indexPath.section==4 && indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kDeleteCell forIndexPath:indexPath];
        _deleteButton = (UIButton *)[cell viewWithTag:kDeleteButtonTag];
        [_deleteButton addTarget:self action:@selector(deleteProfile) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kStandardCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissKeyboard];
    
    if(indexPath.section==0 || indexPath.section==3)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
        [textField becomeFirstResponder];
        
    }
    if([indexPath isEqual:_indexPathForShowCategoryCell] && [self hasSelectedType])
    {
        [self toggleShowCategories];
    }
    
    if(indexPath.section==2 && indexPath.row!=0)
    {
        
        [tableView beginUpdates];
        
        if(_selectedType == kSelectionKaufenKey)
        {
            if([_indexPathForSelectedKaufenCategory isEqual:indexPath])
            {
                _indexPathForSelectedKaufenCategory = nil;
            }
            else
            {
                _indexPathForSelectedKaufenCategory = indexPath;
            }

        }
        else if(_selectedType == kSelectionMietenKey)
        {
            if([_indexPathForSelectedMietenCategory isEqual:indexPath])
            {
                _indexPathForSelectedMietenCategory = nil;
            }
            else
            {
                _indexPathForSelectedMietenCategory = indexPath;
            }
        }
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];

        [tableView endUpdates];
       
    }
    
    if(indexPath.section==4 && indexPath.row==0)
    {
        [self deleteSearchProfile];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(NSString *)selectedCategory
{
    if(_selectedType == kSelectionKaufenKey && _indexPathForSelectedKaufenCategory!=nil)
        return [_immoTypeKaufen objectAtIndex:_indexPathForSelectedKaufenCategory.row-1];
    else if(_selectedType == kSelectionMietenKey && _indexPathForSelectedMietenCategory!=nil)
        return [_immoTypeMieten objectAtIndex:_indexPathForSelectedMietenCategory.row-1];
    else
        return @"Kein";
}

-(void)saveChanges
{
    _searchProfile.location = (_locationField.text? _locationField.text : nil);
    
    NSString *category =  [self selectedCategory];
    if([category isEqualToString:@"Bürofläche"])
    {
        [category stringByAppendingString: (_selectedType==kSelectionKaufenKey ? @"-Ankauf" : @"-Miete")];
    }
    else if([category isEqualToString:@"Kein"])
        category = nil;
    _searchProfile.type = category;
    
    _searchProfile.max_cost = [NSNumber numberWithInteger:[_priceField.text integerValue]];
    _searchProfile.min_size = [NSNumber numberWithInteger:[_sizeField.text integerValue]];
    _searchProfile.min_rooms = [NSNumber numberWithInteger:[_roomsField.text integerValue]];
    
    _searchProfile.timeStamp = [NSDate date];
    
    if(!_editingMode)
        [self.delegate saveNewSearchProfile:_searchProfile ];
    else
        [self.delegate updateSearchProfile];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteSearchProfile{
    [self.delegate deleteSearchProfile:_searchProfile];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)toggleShowCategories
{
    [self.tableView beginUpdates];
        _showCategories = !_showCategories;

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];

    [self.tableView endUpdates];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeTextField = nil;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    UITextField *nextResponder = [self nextResponder:textField];
    if(nextResponder)
        [nextResponder becomeFirstResponder];
    else
        [self dismissKeyboard];
    
    return NO;
}

-(UITextField *)nextResponder:(UITextField *)textField
{
    if(textField == _priceField)
        return _roomsField;
    else if(textField == _roomsField)
        return _sizeField;
    else
        return nil;
}

-(void)dismissKeyboard
{
    [_activeTextField resignFirstResponder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
