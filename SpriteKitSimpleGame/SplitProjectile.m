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
    
    switch (rank) {
        case 3:
        {
            SplitProjectile* splitProjectile4 = [SplitProjectile spriteNodeWithImageNamed:@"snowball"];
            splitProjectile4.size = CGSizeMake(splitProjectile4.size.width/3, splitProjectile4.size.height/3);
            splitProjectile4.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
            splitProjectile4.colorBlendFactor = .5;
            splitProjectile4.damage = 1;
            splitProjectile4 = (SplitProjectile*)[super setProjectileProperties:splitProjectile4];
            splitProjectile4.position = CGPointMake(parentProjectile.position.x, parentProjectile.position.y-10);
            [parentProjectile addChild:splitProjectile4];
        }
        case 2:
        {
            SplitProjectile* splitProjectile3 = [SplitProjectile spriteNodeWithImageNamed:@"snowball"];
            splitProjectile3.size = CGSizeMake(splitProjectile3.size.width/3, splitProjectile3.size.height/3);
            splitProjectile3.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
            splitProjectile3.colorBlendFactor = .5;
            splitProjectile3.damage = 1;
            splitProjectile3 = (SplitProjectile*)[super setProjectileProperties:splitProjectile3];
            splitProjectile3.position = CGPointMake(parentProjectile.position.x, parentProjectile.position.y+10);
            [parentProjectile addChild:splitProjectile3];
        }
        case 1:
        {
            SplitProjectile* splitProjectile2 = [SplitProjectile spriteNodeWithImageNamed:@"snowball"];
            splitProjectile2.size = CGSizeMake(splitProjectile2.size.width/3, splitProjectile2.size.height/3);
            splitProjectile2.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
            splitProjectile2.colorBlendFactor = .5;
            splitProjectile2.damage = 1;
            splitProjectile2 = (SplitProjectile*)[super setProjectileProperties:splitProjectile2];
            splitProjectile2.position = CGPointMake(parentProjectile.position.x+10, parentProjectile.position.y);
            [parentProjectile addChild:splitProjectile2];
            
            SplitProjectile* splitProjectile1 = [SplitProjectile spriteNodeWithImageNamed:@"snowball"];
            splitProjectile1.size = CGSizeMake(splitProjectile1.size.width/3, splitProjectile1.size.height/3);
            splitProjectile1.color = [SKColor colorWithRed:177/255.0 green:198/255.0 blue:0 alpha:1];
            splitProjectile1.colorBlendFactor = .5;
            splitProjectile1.damage = 1;
            splitProjectile1 = (SplitProjectile*)[super setProjectileProperties:splitProjectile1];
            splitProjectile1.position = CGPointMake(parentProjectile.position.x-10, parentProjectile.position.y);
            [parentProjectile addChild:splitProjectile1];
        }
        default:
            break;
    }
    
    [parentProjectile runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:90 duration:10]]withKey:@"spin"];
    
    return parentProjectile;
}
@end
