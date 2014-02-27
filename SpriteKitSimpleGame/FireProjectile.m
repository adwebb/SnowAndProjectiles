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
    FireProjectile* fireProjectile = [FireProjectile spriteNodeWithImageNamed:@"harpoon_white.png"];
    fireProjectile.color = [SKColor colorWithRed:1 green:85/255.0 blue:0 alpha:1];
    fireProjectile.colorBlendFactor = .75;
    fireProjectile.damage = rank+1;
    fireProjectile = (FireProjectile*)[super setProjectileProperties:fireProjectile];
    
    return fireProjectile;
}

@end
