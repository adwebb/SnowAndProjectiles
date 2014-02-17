//
//  SnowballProjectile.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "SnowballProjectile.h"

@implementation SnowballProjectile

+ (SnowballProjectile*)makeSnowballProjectile
{
    SnowballProjectile* snowballProjectile = [SnowballProjectile spriteNodeWithImageNamed:@"snowball"];
    snowballProjectile.damage = 1;
    
    return snowballProjectile;
}

@end
