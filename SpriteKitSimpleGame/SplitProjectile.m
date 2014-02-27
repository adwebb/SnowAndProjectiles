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
    SplitProjectile* parentProjectile = [SplitProjectile new];
    parentProjectile.physicsBody.affectedByGravity = NO;
    [parentProjectile setName:movableNodeName];
    
    for (NSInteger i = 0; i < rank + 1; i++)
    {
        SplitProjectile* splitProjectile4 = [SplitProjectile spriteNodeWithImageNamed:@"harpoon_arrow.png"];
        //splitProjectile4.size = CGSizeMake(splitProjectile4.size.width/2, splitProjectile4.size.height/2);
        splitProjectile4.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
        splitProjectile4.colorBlendFactor = .5;
        splitProjectile4.damage = 1;
        splitProjectile4 = (SplitProjectile*)[super setProjectileProperties:splitProjectile4];
        
        CGFloat offset = i % 2 == 0 ? -.1 : .1;
        
        splitProjectile4.zRotation = offset*i;
        
        [parentProjectile addChild:splitProjectile4];
    }
    
    return parentProjectile;
}
@end
