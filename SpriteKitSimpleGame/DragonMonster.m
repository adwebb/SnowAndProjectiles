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
    DragonMonster* dragonMonster = [DragonMonster spriteNodeWithImageNamed:@"cuteDragon"];
    dragonMonster.size = CGSizeMake(55, 55);

    dragonMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dragonMonster.size];
    dragonMonster.baseSpeed = .5;
    
    dragonMonster.health = 3;
    dragonMonster = (DragonMonster*)[super setMonsterProperties:dragonMonster];
    dragonMonster.goldValue = 6;
    
    SKEmitterNode *dragonBreath = [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource:@"fireBreath" ofType:@"sks"]];
    dragonBreath.position = CGPointMake(-30, -15);
    dragonBreath.name = @"fireBreath";
    
    [dragonMonster addChild:dragonBreath];
    
    return dragonMonster;
}


@end
