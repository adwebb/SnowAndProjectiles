//
//  FireProjectile.m
//  SnowAndProjectiles
//
//  Created by Andrew Webb on 2/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "FireProjectile.h"

@implementation FireProjectile

+(FireProjectile*)fireProjectileOfRank:(int)rank
{
    FireProjectile* fireProjectile = [FireProjectile spriteNodeWithImageNamed:@"snowball"];
    fireProjectile.color = [SKColor colorWithRed:1 green:85/255.0 blue:0 alpha:1];
    fireProjectile.colorBlendFactor = .75;
    fireProjectile.damage = rank;
    fireProjectile = (FireProjectile*)[super setProjectileProperties:fireProjectile];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fireball" ofType:@"sks"];
    SKEmitterNode* fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [fireProjectile addChild:fireEmitter];
    
    return fireProjectile;
}

@end
