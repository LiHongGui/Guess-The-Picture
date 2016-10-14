//
//  GuessModel.h
//  GuessThePicture
//
//  Created by MichaelLi on 2016/10/10.
//  Copyright © 2016年 手持POS机. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuessModel : NSObject

@property(nonatomic,strong) NSString *answer;
@property(nonatomic,strong) NSString *icon;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSArray *options;

//对象方法
-(instancetype)initWith:(NSDictionary *)dict;
//类方法
+(instancetype)guessModelWith:(NSDictionary *)dict;

@end
