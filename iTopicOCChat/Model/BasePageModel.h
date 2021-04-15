//
//  BasePagerData.h
//  tabbarDemo
//
//  Created by DongJin on 14-12-9.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "JSONModel.h"

@interface BasePageModel : JSONModel
{
}

@property (strong, nonatomic) NSNumber<Optional> *totalpage;
@property (strong, nonatomic)  NSNumber<Optional> *currentpage;
@property (strong, nonatomic)  NSNumber<Optional> *nextpage;
@property (strong, nonatomic) NSNumber<Optional> *total;
- (BOOL)hasMore;
@end
