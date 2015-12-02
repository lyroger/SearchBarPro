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
#define GrayWhiteColor          mRGBColor(230, 230, 230)

// 定义这个常量,就可以在使用Masonry不必总带着前缀 `mas_`:
#define MAS_SHORTHAND
// 定义这个常量,以支持在 Masonry 语法中自动将基本类型转换为 object 类型:
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

@interface ViewController ()<UISearchDisplayDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    UITableView *tableViewList;
    
    NSArray *dataArray;
    NSArray *searchDataArray;
    UIButton *btnVoice;
    UIButton *btnCancel;
    UIView  *searchBgView;
    CALayer *topLineLayer;
    CALayer *bottomLayer;
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
    self.view.backgroundColor = GreyishWhiteColor;
    searchDataArray = @[@"搜索第一行"];
    
    if (!self.tempSearchDisplayBackgroungView) {
        self.tempSearchDisplayBackgroungView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mScreenWidth, mScreenHeight)];
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
    
    btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVoice setImage:[UIImage imageNamed:@"icon_voice"] forState:UIControlStateNormal];
    [btnVoice addTarget:self action:@selector(btnVoiceClick) forControlEvents:UIControlEventTouchUpInside];
    
    btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitleColor:mRGBColor(78, 216, 101) forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    
    
    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, mScreenWidth, 44)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"搜索"];
    mySearchBar.backgroundColor = mRGBColor(239, 239, 244);
    mySearchBar.backgroundImage = [self imageFromColor:mRGBColor(239, 239, 244) frame:mySearchBar.bounds];
    for (UIView *subView in mySearchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                searchBarTextField.backgroundColor = [UIColor whiteColor];
                searchBarTextField.layer.borderColor =  mRGBColor(228, 229, 233).CGColor;
                searchBarTextField.layer.borderWidth = 1;
                searchBarTextField.layer.cornerRadius = 4;
                searchBarTextField.tintColor = mRGBColor(78, 216, 101);
                
                CGFloat btnWidth = 25;
                [searchBarTextField addSubview:btnVoice];
                [searchBarTextField.superview addSubview:btnCancel];
                
                [btnVoice makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(-10);
                    make.centerY.equalTo(searchBarTextField.centerY);
                    make.size.equalTo(CGSizeMake(btnWidth, btnWidth));
                }];
                
                [btnCancel makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(searchBarTextField.right).offset(-2);
                    make.centerY.equalTo(searchBarTextField.centerY);
                    make.size.equalTo(CGSizeMake(50, 30));
                }];
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

- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    UIButton *btn = [searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"      " forState:UIControlStateNormal];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length) {
        btnVoice.hidden = YES;
    } else {
        btnVoice.hidden = NO;
    }
}

- (void)btnVoiceClick
{
    NSLog(@"btnVoiceClick");
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    topLineLayer.hidden = YES;
    bottomLayer.hidden = YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self performSelector:@selector(addTipsViewWithView:) withObject:controller afterDelay:0.1];
}

- (void)addTipsViewWithView:(UISearchDisplayController*)controller
{
    UIView *supV = controller.searchResultsTableView.superview;
    UIView *supsupV = supV.superview;
    
    for (UIView *view in supsupV.subviews) {
        for (UIView *sencondView in view.subviews) {
            if ([sencondView isKindOfClass:[NSClassFromString(@"_UISearchDisplayControllerDimmingView") class]])
            {
                NSLog(@"_UISearchDisplayControllerDimmingView");
                if (![sencondView viewWithTag:99]) {
                    [sencondView addSubview:self.tempSearchDisplayBackgroungView];
                }
                sencondView.alpha = 1;
            }
        }
    }
    
    if (!searchBgView) {
        for (UIView *subView in mySearchBar.subviews)
        {
            for (UIView *secondLevelSubview in subView.subviews){
                if ([secondLevelSubview isKindOfClass:[NSClassFromString(@"UISearchBarBackground") class]])
                {
                    [self addBgViewToView:secondLevelSubview];
                    break;
                }
            }
        }
    } else {
        topLineLayer.hidden = NO;
        bottomLayer.hidden = NO;
    }
}

- (void)addBgViewToView:(UIView*)view
{
    if (!searchBgView) {
        searchBgView = [[UIView alloc] init];
        searchBgView.tag = 100;
        searchBgView.backgroundColor = mRGBColor(239, 239, 244);
        [view addSubview:searchBgView];
        
        [searchBgView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.left);
            make.right.equalTo(view.right);
            make.top.equalTo(view.top);
            make.bottom.equalTo(view.bottom);
        }];
        
        topLineLayer = [CALayer layer];
        topLineLayer.frame = CGRectMake(0, 20, mScreenWidth, 1);
        topLineLayer.backgroundColor = GrayWhiteColor.CGColor;
        [searchBgView.layer addSublayer:topLineLayer];
        
        bottomLayer = [CALayer layer];
        bottomLayer.frame = CGRectMake(0, 63, mScreenWidth, 1);
        bottomLayer.backgroundColor = GrayWhiteColor.CGColor;
        [searchBgView.layer addSublayer:bottomLayer];
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
