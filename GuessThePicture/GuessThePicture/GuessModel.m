//
//  GuessModel.m
//  GuessThePicture
//
//  Created by MichaelLi on 2016/10/10.
//  Copyright © 2016年 手持POS机. All rights reserved.
//

#import "GuessModel.h"

@implementation GuessModel


-(instancetype)initWith:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(instancetype)guessModelWith:(NSDictionary *)dict
{
    return [[self alloc]initWith:dict];
}
@end
