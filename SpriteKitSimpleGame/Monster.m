//
//  Monster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Monster.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t heroCategory           =  0x11;

@implementation Monster

+ (Monster*)setMonsterProperties:(Monster*)monster
{
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.affectedByGravity = NO;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = heroCategory | projectileCategory | monsterCategory;
    monster.physicsBody.collisionBitMask = 0;
    monster.physicsBody.usesPreciseCollisionDetection = YES;
    monster.speed = monster.baseSpeed;
    return monster;
}

@end
