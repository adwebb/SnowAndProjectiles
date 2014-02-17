//
//  Monster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Monster.h"

static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t projectileCategory     =  0x1 << 0;

@implementation Monster

+ (Monster*)setMonsterProperties:(Monster*)monster
{
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.affectedByGravity = NO;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
    return monster;
}

+ (Monster *) monster {
    return nil;
}
@end
