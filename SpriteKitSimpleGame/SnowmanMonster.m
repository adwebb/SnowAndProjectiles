//
//  SnowmanMonster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//



#import "SnowmanMonster.h"

@implementation SnowmanMonster

+ (SnowmanMonster*)monster
{
    SnowmanMonster* snowmanMonster = [SnowmanMonster spriteNodeWithImageNamed:@"snowman"];
    snowmanMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:snowmanMonster.size];
    snowmanMonster.health = 1;
    snowmanMonster.goldValue = 1;
    snowmanMonster = (SnowmanMonster*)[super setMonsterProperties:snowmanMonster];
    snowmanMonster.goldValue = 2;
    
    
    return snowmanMonster;
}

@end
