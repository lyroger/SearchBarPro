//
//  ViewController.m
//  SearchBarPro
//
//  Created by luoyan on 15/9/10.
//  Copyright (c) 2015年 luoyan. All rights reserved.
//

#import "ViewController.h"

#define mScreenWidth            ([UIScreen mainScreen].bounds.size.width)
#define mScreenHeight           ([UIScreen mainScreen].bounds.size.height)
#define mRGBColor(r, g, b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define GreyishWhiteColor       mRGBColor(242, 242, 242)

@interface ViewController ()<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    UITableView *tableViewList;
    
    NSArray *dataArray;
    NSArray *searchDataArray;
}
@property (nonatomic,strong) UIView *tempSearchDisplayBackgroungView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"search";
    [self loadSubView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadSubView
{
    dataArray = @[@"第一行",@"第二行",@"第三行",@"第四行",@"第五行"];
    searchDataArray = @[@"搜索第一行",@"搜索第二行",@"搜索第三行",@"搜索第四行",@"搜索第五行"];
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, mScreenWidth, 40)];
    mySearchBar.delegate = self;
    mySearchBar.barTintColor = [UIColor whiteColor];
    [mySearchBar setPlaceholder:@"搜索"];
    UIColor *bgColor = [UIColor colorWithRed:0xff green:0xff blue:0xff alpha:1];
    mySearchBar.backgroundImage = [self imageFromColor:bgColor frame:mySearchBar.bounds];
    for (UIView *subView in mySearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
//                searchBarTextField.textColor = mRGBColor(155, 155, 155);
                searchBarTextField.backgroundColor = GreyishWhiteColor;
                break;
            }
        }
    }
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [searchDisplayController.searchResultsTableView setTableFooterView:view];
    [searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    tableViewList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, mScreenWidth, self.view.frame.size.height-50-64) style:UITableViewStyleGrouped];
    tableViewList.backgroundColor = [UIColor clearColor];
    tableViewList.tableHeaderView = mySearchBar;
    tableViewList.tableFooterView = view;
    tableViewList.delegate = self;
    tableViewList.dataSource = self;
    [tableViewList setContentOffset:CGPointMake(0, tableViewList.tableHeaderView.frame.size.height)];
    [tableViewList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableViewList];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self performSelector:@selector(addTipsViewWithView:) withObject:controller afterDelay:0.1];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.tempSearchDisplayBackgroungView.hidden = YES;
}

- (void)addTipsViewWithView:(UISearchDisplayController*)controller
{
    NSLog(@"subViews.count = %zd",controller.searchResultsTableView.superview.subviews.count);
    NSLog(@"superView %@",[controller.searchResultsTableView.superview class]);
    UIView *supV = controller.searchResultsTableView.superview;
    UIView *supsupV = supV.superview;
    if (!self.tempSearchDisplayBackgroungView) {
        self.tempSearchDisplayBackgroungView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, mScreenWidth, mScreenHeight)];
        self.tempSearchDisplayBackgroungView.backgroundColor = [UIColor whiteColor];
        self.tempSearchDisplayBackgroungView.tag = 99;
        self.tempSearchDisplayBackgroungView.userInteractionEnabled = NO;
        
        NSString *tips = @"搜索更多的内容";
        CGSize font = [tips sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
        UILabel *labelTips = [[UILabel alloc] initWithFrame:CGRectMake((mScreenWidth-font.width)/2, 50, font.width, font.height)];
        labelTips.font = [UIFont systemFontOfSize:20];
        labelTips.text = tips;
        labelTips.textColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.tempSearchDisplayBackgroungView addSubview:labelTips];
        
        CALayer *line = [CALayer layer];
        line.frame = CGRectMake(labelTips.frame.origin.x-30, labelTips.frame.origin.y+labelTips.frame.size.height+15, font.width+30*2, 0.5);
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        line.opacity = 0.5;
        [self.tempSearchDisplayBackgroungView.layer addSublayer:line];
        
    }
    if (![supsupV viewWithTag:99]) {
        [supsupV addSubview:self.tempSearchDisplayBackgroungView];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (searchBar.text.length) {
        self.tempSearchDisplayBackgroungView.hidden = YES;
    } else {
        self.tempSearchDisplayBackgroungView.hidden = NO;
        self.tempSearchDisplayBackgroungView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^(){
            self.tempSearchDisplayBackgroungView.alpha = 1;
        }];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar.text.length) {
        self.tempSearchDisplayBackgroungView.hidden = YES;
    } else {
        self.tempSearchDisplayBackgroungView.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:tableViewList]) {
        return dataArray.count;
    } else {
        return searchDataArray.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if ([tableView isEqual:tableViewList]) {
        cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [searchDataArray objectAtIndex:indexPath.row];
    }
    return cell;
}

- (UIImage *)imageFromColor:(UIColor *)color frame:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
