//
//  Hero.m
//  SnowAndProjectiles
//
//  Created by Fletcher Rhoads on 2/13/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "Hero.h"

@implementation Hero

+ (Hero*)spawnHero
{
    Hero* hero = [Hero spriteNodeWithImageNamed:@"hero"];
    return hero;
}

@end
