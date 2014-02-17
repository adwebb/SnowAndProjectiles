//
//  Hero2.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Hero.h"

static const uint32_t monsterCategory     =  0x1 << 1;
static const uint32_t heroCategory        =  0x11;

@implementation Hero

+(Hero*)spawnHero
{
    Hero* hero = [Hero spriteNodeWithImageNamed:@"hero"];
    hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hero.size];
    hero.physicsBody.categoryBitMask = heroCategory;
    hero.physicsBody.contactTestBitMask = monsterCategory;
    hero.physicsBody.collisionBitMask = 0;
    hero.physicsBody.affectedByGravity = NO;
    hero.physicsBody.dynamic = YES;
    hero.health = 3;
    
    return hero;
}

@end
