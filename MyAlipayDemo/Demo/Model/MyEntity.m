//
//  MyEntity.m
//  MyAlipayDemo
//
//  Created by ChangWingchit on 2017/4/8.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "MyEntity.h"

@implementation MyEntity

- (id)initWithTitle:(NSString *)title body:(NSString *)body price:(float)price
{
    if (self = [super init]) {
        self.subject = title;
        self.body = body;
        self.price = price;
    }
    return self;
}

@end
