//
//  MyVc.m
//  MyAlipayDemo
//
//  Created by ChangWingchit on 2017/4/8.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "MyVc.h"
#import "MyEntity.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RSADataSigner.h"
#import "Order.h"

@interface MyVc ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *aryData;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation MyVc

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付宝SDK";
    
    //准备数据源
    [self prepareData];
    
    //初始化子视图
    [self initWithSubViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)prepareData
{
    MyEntity *ety1 = [[MyEntity alloc] initWithTitle:@"商品1" body:@"swift" price:2.1];
    MyEntity *ety2 = [[MyEntity alloc] initWithTitle:@"商品2" body:@"C语言" price:1.1];
    MyEntity *ety3 = [[MyEntity alloc] initWithTitle:@"商品3" body:@"iOS0" price:13.5];
    MyEntity *ety4 = [[MyEntity alloc] initWithTitle:@"商品4" body:@"iOS1" price:22.3];
    MyEntity *ety5 = [[MyEntity alloc] initWithTitle:@"商品5" body:@"iOS2" price:125.14];
    MyEntity *ety6 = [[MyEntity alloc] initWithTitle:@"商品6" body:@"iOS3" price:321.6];
    MyEntity *ety7 = [[MyEntity alloc] initWithTitle:@"商品7" body:@"小孩玩具-小车" price:12.8];
    MyEntity *ety8 = [[MyEntity alloc] initWithTitle:@"商品8" body:@"洗衣服-立白" price:2.9];
    MyEntity *ety9 = [[MyEntity alloc] initWithTitle:@"商品9" body:@"茶叶-毛尖" price:4.1];
    MyEntity *ety10 = [[MyEntity alloc] initWithTitle:@"商品10" body:@"手机-iphone6" price:2.7];
    MyEntity *ety11 = [[MyEntity alloc] initWithTitle:@"商品11" body:@"手机-iphone6 plus" price:26.1];
    MyEntity *ety12 = [[MyEntity alloc] initWithTitle:@"商品12" body:@"手机-ipad4" price:72.3];
    self.aryData = @[ety1,ety2,ety3,ety4,ety5,ety6,ety7,ety8,ety9,ety10,ety11,ety12];
}

- (void)initWithSubViews
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];

}

//生成随机字符串
- (NSString*)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc]init];
    srand((unsigned)time(0));
    for (int i = 0;i<kNumber;i++)
    {
        unsigned index = rand()%[sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.aryData && [self.aryData count]) {
        return [self.aryData count];
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    if (self.aryData && indexPath.row < [self.aryData count]) {
        MyEntity *ety = (MyEntity*)[self.aryData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  %@  价格：%.2f", ety.subject,ety.body,ety.price];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [self.aryData count])
    {
        //获取商品信息
        MyEntity *entity = [self.aryData objectAtIndex:indexPath.row];
        NSLog(@"商品标题：%@,商品内容：%@,商品价格：%f",entity.subject,entity.body,entity.price);
        
        /*============================================================================*/
        /*=======================需要填写商户app申请的===================================*/
        /*============================================================================*/
        NSString *appID = @"";
        //rsa2更安全，如果两个私钥都申请了，优先使用rsa2
        NSString *rsa2PrivateKey = @"";
        NSString *rsaPrivateKey = @"";
        /*============================================================================*/
        /*============================================================================*/
        /*============================================================================*/
        
        if ([appID length] == 0 || [rsa2PrivateKey length] == 0 || [rsaPrivateKey length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"缺少密钥或者appID"
                                                              delegate:self
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        Order* order = [Order new];
        
        // NOTE: app_id设置
        order.app_id = appID;
        
        // NOTE: 支付接口名称,参数编码格式,当前时间点,支付版本,sign_type 根据商户设置的私钥来决定(默认)
        order.method = @"alipay.trade.app.pay";
        order.charset = @"utf-8";
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        order.timestamp = [formatter stringFromDate:[NSDate date]];
        order.version = @"1.0";
        order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
        
        // NOTE: 商品数据
        order.biz_content = [BizContent new];
        order.biz_content.body = entity.body;
        order.biz_content.subject = entity.subject;
        order.biz_content.out_trade_no = [self generateTradeNO]; //订单ID（由商家自行制定）
        order.biz_content.timeout_express = @"30m"; //超时时间设置
        order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", entity.price]; //商品价格
        
        //将商品信息拼接成字符串
        NSString *orderInfo = [order orderInfoEncoded:NO];
        NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
        NSLog(@"orderSpec = %@",orderInfo);
        
        // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
        //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
        NSString *signedString = nil;
        RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
        if ((rsa2PrivateKey.length > 1)) {
            signedString = [signer signString:orderInfo withRSA2:YES];
        } else {
            signedString = [signer signString:orderInfo withRSA2:NO];
        }
        
        // NOTE: 如果加签成功，则继续执行支付
        if (signedString != nil) {
            //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
            NSString *appScheme = @"alisdkdemo";
            
            // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                     orderInfoEncoded, signedString];
            
            // NOTE: 调用支付结果开始支付
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
            }];
        }
        
    }
 
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
