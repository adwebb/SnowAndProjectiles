//
//  Projectile.h
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

static NSString * const movableNodeName = @"movable";

#import <SpriteKit/SpriteKit.h>

@interface Projectile : SKSpriteNode
@property float damage;
@property int rank;

+ (Projectile*)setProjectileProperties:(Projectile*)projectile;


@end
