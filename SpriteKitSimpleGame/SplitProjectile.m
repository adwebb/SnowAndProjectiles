//
//  SplitProjectile.m
//  SnowAndProjectiles
//
//  Created by Andrew Webb on 2/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "SplitProjectile.h"

@implementation SplitProjectile
+(SplitProjectile*)splitProjectileOfRank:(int)rank
{
    
    
    SplitProjectile* splitProjectile1 = [SplitProjectile spriteNodeWithImageNamed:@"snowball"];
    splitProjectile1.size = CGSizeMake(splitProjectile1.size.width/3, splitProjectile1.size.height/3);
    splitProjectile1.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
    splitProjectile1.colorBlendFactor = .5;
    splitProjectile1.damage = 1;
    splitProjectile1 = (SplitProjectile*)[super setProjectileProperties:splitProjectile1];
    
    
    
    return splitProjectile1;
}
@end
