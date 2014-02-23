//
//  MyScene.h
//  SpriteKitSimpleGame
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : int {
    GameRunning      = 0,
    GameOver         = 1,
    GameSave         = 2,
} GameState;


@interface MyScene : SKScene <NSCoding>

-(void)save;
-(void)load;

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL continued;

@end
