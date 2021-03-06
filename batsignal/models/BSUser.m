//
//  BSUser.m
//  batsignal
//
//  Created by Kyle Warren on 4/29/13.
//  Copyright (c) 2013 Kyle Warren. All rights reserved.
//

#import "BSUser.h"


@implementation BSUser

@dynamic id;
@dynamic name;
@dynamic handle;
@dynamic updatedAt;
@dynamic beacons;

+ (NSString *)modelName
{
    return @"BSUser";
}

+ (NSString *)modelUrl
{
    return @"/users";
}

+ (NSDictionary *)keyMap
{
    return @{@"name": @"name",
             @"handle": @"handle"};
}

- (NSDictionary *)asDict
{
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:@[@"id", @"handle"]] mutableCopy];
    
    return dict;
}

@end
