//
//  SnowballProjectile.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "SnowballProjectile.h"

@implementation SnowballProjectile

+ (SnowballProjectile*)snowballProjectile
{
    SnowballProjectile* snowballProjectile = [SnowballProjectile spriteNodeWithImageNamed:@"harpoon_arrow"];
    snowballProjectile.damage = 1;
    snowballProjectile = (SnowballProjectile*)[super setProjectileProperties:snowballProjectile];
    
    return snowballProjectile;
}

@end
