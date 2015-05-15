//
//  JLTableViewReloadManager.m
//  TableViewReload
//
//  Created by Joey L. on 5/15/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "JLTableViewReloadManager.h"

@interface JLTableViewReloadManager ()
{
    
}
// key : memory address of UITableView
// value : UITableView
@property (strong, nonatomic) NSMutableDictionary *tableViewDict;

// key : memory address of UITableView
// value : array of NSDictionary which contains completion block for key named "completion"
@property (strong, nonatomic) NSMutableDictionary *queuesDict;

@end

@implementation JLTableViewReloadManager

static JLTableViewReloadManager *instance = nil;

#pragma mark -
#pragma mark singleton

+ (JLTableViewReloadManager *)sharedInstance
{
    @synchronized(self)
    {
        if (!instance)
            instance = [[JLTableViewReloadManager alloc] init];
        
        return instance;
    }
    
}

#pragma mark - accessor

- (NSMutableDictionary *)tableViewDict
{
    if(!_tableViewDict) {
        _tableViewDict = [[NSMutableDictionary alloc] init];
    }
    return _tableViewDict;
}

- (NSMutableDictionary *)queuesDict
{
    if(!_queuesDict) {
        _queuesDict = [[NSMutableDictionary alloc] init];
    }
    return _queuesDict;
}

#pragma mark -

+ (void)reloadTableView:(UITableView *)tableView completion:(JLTableViewReloadCompletion)completion
{
    if(!tableView) {
        if(completion) {
            completion();
        }
        return;
    }
    [[JLTableViewReloadManager sharedInstance] reloadTableView:tableView completion:completion];
}
- (void)reloadTableView:(UITableView *)tableView completion:(JLTableViewReloadCompletion)completion
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(tableView) [dict setObject:tableView forKey:@"tableView"];
    if(completion) [dict setObject:completion forKey:@"completion"];
    
    [self performSelectorOnMainThread:@selector(reloadTableViewAction:) withObject:dict waitUntilDone:NO];
}
- (void)reloadTableViewAction:(NSDictionary *)dict
{
    UITableView *tableView = dict[@"tableView"];
    JLTableViewReloadCompletion completion = dict[@"completion"];
    
    NSString *key = [NSString stringWithFormat:@"%lx", (long)tableView];
    
    // add data
    [self.tableViewDict setObject:tableView forKey:key];
    
    NSMutableDictionary *queueDict = [NSMutableDictionary dictionary];
    if(completion)
        [queueDict setObject:completion forKey:@"completion"];
    
    NSMutableArray *queue = self.queuesDict[key];
    if(!queue) {
        queue = [NSMutableArray array];
        [self.queuesDict setObject:queue forKey:key];
    }
    [queue addObject:queueDict];
    
    
    // start if necessary
    if(queue.count == 1) {
        [self executeQueueForKey:key];
    }
    
}

- (void)executeQueueForKey:(NSString *)key
{
    NSArray *queue = self.queuesDict[key];
    if(queue.count == 0) {
        [self.queuesDict removeObjectForKey:key];
        [self.tableViewDict removeObjectForKey:key];
        return;
    }

    NSMutableDictionary *dict = queue[0];
    [dict setObject:key forKey:@"key"];
    
    UITableView *tableView = self.tableViewDict[key];
    [tableView reloadData];
    [self performSelector:@selector(reloadDataCompleted:) withObject:dict afterDelay:0.001];

}

- (void)reloadDataCompleted:(NSDictionary *)dict
{
    NSString *key = dict[@"key"];

    JLTableViewReloadCompletion completion = dict[@"completion"];
    if(completion) {
        completion();
    }
    
    NSMutableArray *queue = self.queuesDict[key];
    [queue removeObjectAtIndex:0];
    
    
    [self executeQueueForKey:key];
}


@end
