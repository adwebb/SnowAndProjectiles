//
//  SnowmanMonster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//



#import "Minion.h"

@implementation Minion

+ (Minion*)monster
{
    Minion* snowmanMonster = [Minion spriteNodeWithImageNamed:@"shark_fish"];
    snowmanMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:snowmanMonster.size];
    snowmanMonster.health = 1;
    snowmanMonster.baseSpeed = 1;
    snowmanMonster.ScoreValue = 5;
    snowmanMonster.damage = 1;
    snowmanMonster = (Minion*)[super setMonsterProperties:snowmanMonster];
    snowmanMonster.goldValue = 2;
    
    
    return snowmanMonster;
}

@end
