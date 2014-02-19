//
//  DragonMonster.m
//  SnowAndProjectiles
//
//  Created by gule on 2/18/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "DragonMonster.h"

@implementation DragonMonster


+ (DragonMonster*)monster
{
    DragonMonster* dragonMonster = [DragonMonster spriteNodeWithImageNamed:@"cuteDragonSmall"];
    dragonMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dragonMonster.size];
    dragonMonster.baseSpeed = .5;
    dragonMonster.health = 3;
    dragonMonster = (DragonMonster*)[super setMonsterProperties:dragonMonster];
    dragonMonster.goldValue = 10;
    
    return dragonMonster;
}

@end
