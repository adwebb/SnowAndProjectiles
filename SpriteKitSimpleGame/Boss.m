//
//  Boss.m
//  Avast
//
//  Created by Andrew Webb on 2/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Boss.h"

@implementation Boss

+ (Boss*)monster
{
    Boss* boss = [Boss spriteNodeWithImageNamed:@"kraken"];
    boss.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:boss.size];
    boss.baseSpeed = 1.5;
    boss.damage = 10;
    boss.ScoreValue = 500;
    boss.health = 10;
    boss = (Boss*)[super setMonsterProperties:boss];
    boss.goldValue = 100;
    
    return boss;
}

@end
