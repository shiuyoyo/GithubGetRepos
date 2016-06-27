//
//  ViewController.m
//  GithubGetRepos
//
//  Created by shiusimpletonyoyo on 2016/6/26.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"
#import "SVProgressHUD.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, retain) NSMutableDictionary *responseDetailDic;
@property (nonatomic, retain) NSMutableArray *responseReposArray;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic) int pagesCount;
@property (nonatomic) int currentPage;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, weak) IBOutlet UITableView *reposTable;
@property (nonatomic, weak) IBOutlet UISearchBar *userSearchBar;
@end

@implementation ViewController
@synthesize responseDetailDic;
@synthesize responseReposArray;
@synthesize userName;
@synthesize pagesCount;
@synthesize currentPage;
@synthesize isLoading;

@synthesize reposTable;
@synthesize userSearchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    isLoading = NO;

    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Get User Data
- (void)getUserDetail
{
    NSString *getUrlString = [NSString stringWithFormat:@"https://api.github.com/users/%@",userName];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:getUrlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        
        responseDetailDic = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        
        pagesCount = ceil([[responseDetailDic objectForKey:@"public_repos"] intValue]/30.0);

        NSLog(@"Repos Count: %@, Pages Count: %i",[responseDetailDic objectForKey:@"public_repos"],pagesCount);
       
        [self getUserRepos:currentPage];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }];
}

- (void)getUserRepos:(int)page
{
    isLoading = YES;
    
    NSString *userReposUrl = [NSString stringWithFormat:@"https://api.github.com/users/%@/repos?page=%i",userName,page];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:userReposUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        //save response data in an array
        if (responseReposArray == nil) {
            responseReposArray = [NSMutableArray new];
            [responseReposArray addObjectsFromArray:responseObject];
        }else{
            [responseReposArray addObjectsFromArray:responseObject];
        }
        
        [reposTable reloadData];
        
        //when loading finished
        isLoading = NO;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }];
}

#pragma mark - Searchbar Delegate
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

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [responseReposArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reposTableIdentifier = @"ReposTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reposTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reposTableIdentifier];
    }
    
    //show the name of repos
    cell.textLabel.text = [[responseReposArray objectAtIndex:indexPath.row] objectForKey:@"full_name"];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // distinguish is download or not
    if (isLoading)
        return;
    
//    NSLog(@"%f,%f,%f,%f",scrollView.contentOffset.y,scrollView.contentSize.height,scrollView.frame.size.height,self.view.bounds.size.height);
    
    // distinguish scrolling in where
    if ((scrollView.contentSize.height - scrollView.contentOffset.y) <= self.view.bounds.size.height && (currentPage < pagesCount))
    {
        // load more data
        currentPage += 1;
        [self getUserRepos:currentPage];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
