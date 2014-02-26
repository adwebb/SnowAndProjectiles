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
    GameWon          = 2,
} GameState;


@interface GameScene : SKScene 

-(void)save;
-(void)load;
-(id)initWithSize:(CGSize)size continued:(BOOL)continued;


@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic) BOOL muted;

@end
