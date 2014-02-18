//
//  Projectile.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Projectile.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@implementation Projectile

+ (Projectile*)setProjectileProperties:(Projectile*)projectile;
{
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.affectedByGravity = NO;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.alpha = 1;
    [projectile setName:movableNodeName];

    return projectile;
}

@end
