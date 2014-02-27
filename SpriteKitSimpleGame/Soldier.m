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
    Soldier* dragonMonster = [Soldier spriteNodeWithImageNamed:@"starfish"];

    dragonMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:dragonMonster.size];
    dragonMonster.baseSpeed = .5;
    dragonMonster.damage = 2;
    dragonMonster.ScoreValue = 15;
    
    dragonMonster.health = 3;
    dragonMonster = (Soldier*)[super setMonsterProperties:dragonMonster];
    dragonMonster.goldValue = 6;
    
    return dragonMonster;
}


@end
