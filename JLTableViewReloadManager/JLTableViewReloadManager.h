//
//  JLTableViewReloadManager.h
//  TableViewReload
//
//  Created by Joey L. on 5/15/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^JLTableViewReloadCompletion)(void);

@interface JLTableViewReloadManager : NSObject

+ (void)reloadTableView:(UITableView *)tableView completion:(JLTableViewReloadCompletion)completion;

@end
