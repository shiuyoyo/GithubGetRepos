//
//  ViewController.m
//  GithubGetRepos
//
//  Created by shiusimpletonyoyo on 2016/6/26.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, retain) NSMutableDictionary *responseDetailDic;
@property (nonatomic, strong) NSMutableArray *responseReposArray;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic) int pagesCount;
@property (nonatomic) int currentPage;
@property (nonatomic, retain) IBOutlet UITableView *reposTable;
@property (nonatomic, retain) IBOutlet UISearchBar *userSearchBar;
@property (nonatomic) BOOL isLoading;
@end

@implementation ViewController
@synthesize responseDetailDic;
@synthesize responseReposArray;
@synthesize userName;
@synthesize pagesCount;
@synthesize currentPage;
@synthesize reposTable;
@synthesize userSearchBar;
@synthesize isLoading;

- (void)viewDidLoad {
    [super viewDidLoad];
    isLoading = NO;

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)getUserDetail
{
    NSString *getUrlString = [NSString stringWithFormat:@"https://api.github.com/users/%@",userName];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:getUrlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        responseDetailDic = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        
        pagesCount = ceil([[responseDetailDic objectForKey:@"public_repos"] intValue]/30.0);

        NSLog(@"Detail :%@, Repos Count%i",[responseDetailDic objectForKey:@"public_repos"],pagesCount);
       
        [self getUserRepos:currentPage];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getUserRepos:(int)page
{
    isLoading = YES;
    
    NSString *userReposUrl = [NSString stringWithFormat:@"https://api.github.com/users/%@/repos?page=%i",userName,page];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:userReposUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        if (responseReposArray == nil) {
            responseReposArray = [NSMutableArray arrayWithObject:responseObject];
        }else{
            [responseReposArray addObjectsFromArray:responseObject];
        }
        
        [reposTable reloadData];
        
        isLoading = NO;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    NSLog(@"%@",searchBar.text);
    if ([searchBar.text length] >0) {
        userName = searchBar.text;
        currentPage = 1;
        responseReposArray = nil;
        [self getUserDetail];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[responseReposArray objectAtIndex:0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reposTableIdentifier = @"ReposTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reposTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reposTableIdentifier];
    }
    
    //顯示repos的名字
    cell.textLabel.text = [[[responseReposArray objectAtIndex:0] objectAtIndex:indexPath.row] objectForKey:@"full_name"];
    [cell.textLabel sizeToFit];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 判斷目前是否正在載入資料
    if (isLoading)
        return;
    
    // 判斷滾到哪裡的時候要自動載入更多，這可以依需求調整
    NSLog(@"%f,%f,%f",scrollView.contentOffset.y,scrollView.contentSize.height,scrollView.frame.size.height);
    
    if ((scrollView.contentOffset.y*2 >= scrollView.contentSize.height) && (currentPage < pagesCount))
    {
        // 載入更多的動作寫在這裡
        currentPage+=1;
        [self getUserRepos:currentPage];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
