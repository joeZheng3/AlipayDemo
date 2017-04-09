//
//  MyEntity.h
//  MyAlipayDemo
//
//  Created by ChangWingchit on 2017/4/8.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEntity : NSObject

@property (nonatomic) float price; //价格
@property (nonatomic,strong) NSString *subject; //标题
@property (nonatomic,strong) NSString *body; //内容

- (id)initWithTitle:(NSString*)title body:(NSString*)body price:(float)price;

@end
