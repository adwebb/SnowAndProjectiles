//
//  YetiMonster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "YetiMonster.h"

@implementation YetiMonster

+ (YetiMonster*)monster
{
    YetiMonster* yetiMonster = [YetiMonster spriteNodeWithImageNamed:@"yeti"];
    yetiMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:yetiMonster.size];
    yetiMonster.baseSpeed = 1;
    yetiMonster.damage = 1;
    yetiMonster.ScoreValue = 10;
    yetiMonster.health = 2;
    yetiMonster = (YetiMonster*)[super setMonsterProperties:yetiMonster];
    yetiMonster.goldValue = 4;
    
    return yetiMonster;
}

@end
