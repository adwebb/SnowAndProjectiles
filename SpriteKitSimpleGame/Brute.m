//
//  YetiMonster.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Brute.h"

@implementation Brute

+ (Brute*)monster
{
    Brute* yetiMonster = [Brute spriteNodeWithImageNamed:@"squid_mouth"];
    yetiMonster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:yetiMonster.size];
    yetiMonster.baseSpeed = 1;
    yetiMonster.damage = 1;
    yetiMonster.ScoreValue = 10;
    yetiMonster.health = 2;
    yetiMonster = (Brute*)[super setMonsterProperties:yetiMonster];
    yetiMonster.goldValue = 4;
    
    return yetiMonster;
}

@end
