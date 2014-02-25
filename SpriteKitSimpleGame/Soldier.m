//
//  DragonMonster.m
//  SnowAndProjectiles
//
//  Created by gule on 2/18/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Soldier.h"

@implementation Soldier


+ (Soldier*)monster
{
    Soldier* dragonMonster = [Soldier spriteNodeWithImageNamed:@"cuteDragon"];
    dragonMonster.size = CGSizeMake(55, 55);

    dragonMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dragonMonster.size];
    dragonMonster.baseSpeed = .5;
    dragonMonster.damage = 2;
    dragonMonster.ScoreValue = 15;
    
    dragonMonster.health = 3;
    dragonMonster = (Soldier*)[super setMonsterProperties:dragonMonster];
    dragonMonster.goldValue = 6;
    
    SKEmitterNode *dragonBreath = [NSKeyedUnarchiver unarchiveObjectWithFile: [[NSBundle mainBundle] pathForResource:@"fireBreath" ofType:@"sks"]];
    dragonBreath.position = CGPointMake(-30, -15);
    dragonBreath.name = @"fireBreath";
    
    [dragonMonster addChild:dragonBreath];
    
    return dragonMonster;
}


@end
