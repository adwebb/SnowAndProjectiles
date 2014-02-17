//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "SnowmanMonster.h"
#import "YetiMonster.h"
#import "Hero.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min, CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                  (max - min) + min);
}

@interface MyScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer* panGestureRecognizer;
    CGPoint projectileSpawnPoint;
    
    SKLabelNode *_playerHealthLabel;
    NSString    *_healthBar;
    SKAction *_scoreFlashAction;
    SKAction    *_gameOverPulse;
    SKLabelNode *_gameOverLabel;
    SKNode *_hudLayerNode;
    SKLabelNode *_tapScreenLabel;
    
    CGFloat _score;


    
}
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
@property (nonatomic) SKSpriteNode* projectile;

@end

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}
 
static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}
 
static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}
 
static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint rwInvert(CGPoint point)
{
    return CGPointMake(-point.x, -point.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@implementation MyScene
 
-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
 
        // Loading the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.jpg"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        _hudLayerNode = [SKNode node];
        [self addChild:_hudLayerNode];
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
  
        //self.player = [SKSpriteNode spriteNodeWithImageNamed:@"hero"];
        
        Hero* hero = [Hero spawnHero];
        hero.position = CGPointMake(self.player.size.width*2, self.frame.size.height*2/5);

        [self addChild:self.player];
        
        projectileSpawnPoint = CGPointMake(self.player.size.width*2, self.frame.size.height*2/5+self.player.size.height/2);
        

        NSString *snowPath = [[NSBundle mainBundle] pathForResource:@"backgroundSnow" ofType:@"sks"];
        SKEmitterNode* snowEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:snowPath];
        snowEmitter.position = CGPointMake(self.frame.size.width/2, self.frame.size.height+10);
        [_background addChild:snowEmitter];
        
        [self spawnProjectile];
        
        self.physicsWorld.gravity = CGVectorMake(0,-5);
        self.physicsWorld.contactDelegate = self;
        
        [self setupUI];
        
    }
    return self;
}

-(void)spawnProjectile
{
    self.projectile = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
    self.projectile.physicsBody.affectedByGravity = NO;
    self.projectile.position = projectileSpawnPoint;
    self.projectile.alpha = 1;
    [self.projectile setName:movableNodeName];
    [self addChild:self.projectile];
   // [self.projectile runAction:[SKAction fadeInWithDuration:1]];
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if(self.projectile.alpha == 1 && self.projectile.physicsBody.affectedByGravity == NO)
    {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self selectNodeForTouch:touchLocation];
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:recognizer.view];
            translation = CGPointMake(translation.x, -translation.y);
            [self panForTranslation:translation fromStartPoint:touchLocation];
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
            
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            
            if ([[_selectedNode name] isEqualToString:movableNodeName]) {
                
                CGPoint location = self.projectile.position;
                CGPoint offset = rwSub(location, projectileSpawnPoint);
                
                // Bail out if you are shooting down or backwards
                if (offset.x >= 0) return;
                
                // Get the direction of where to shoot
                CGPoint direction = rwNormalize(offset);
                CGPoint launchDirection = rwInvert(direction);
                float force = rwLength(offset);
                CGPoint multiplied = rwMult(launchDirection, force/3);
                CGVector launcher = CGVectorMake(multiplied.x, multiplied.y);
                
                self.projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.projectile.size.width/2];
                self.projectile.physicsBody.dynamic = YES;
                self.projectile.physicsBody.categoryBitMask = projectileCategory;
                self.projectile.physicsBody.contactTestBitMask = monsterCategory;
                self.projectile.physicsBody.collisionBitMask = 0;
                self.projectile.physicsBody.usesPreciseCollisionDetection = YES;
                
                self.projectile.physicsBody.affectedByGravity = YES;
                [self.projectile.physicsBody applyImpulse:launcher];
            }
        }
    }
}

- (void)panForTranslation:(CGPoint)translation fromStartPoint:(CGPoint)point
{
    if([self isWithinSlingshotDragArea:point])
    {
        CGPoint position = self.projectile.position;
        CGPoint newPosition = CGPointMake(position.x + translation.x, position.y + translation.y);
        if([self isWithinSlingshotDragArea:newPosition]) {
            [self.projectile setPosition:newPosition];
        }
    }
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    if([self isWithinSlingshotDragArea:touchLocation])
    {
        SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
                                                  [SKAction rotateByAngle:0.0 duration:0.1],
                                                  [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];
    [self.projectile runAction:[SKAction repeatActionForever:sequence]];
        _selectedNode = self.projectile;
    }
}

-(BOOL)isWithinSlingshotDragArea:(CGPoint)point
{
    if(point.x < projectileSpawnPoint.x)
    {
        return YES;
    }
    return NO;
}

float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}

- (void)addMonster {
 
    SKLabelNode *mainShip = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    mainShip.name = @"mainship";
    mainShip.fontSize = 50.0f;
    mainShip.text = @"🚀";
    mainShip.zRotation = 0.8;

    
    int monsterPicker = arc4random()%2+1;
    
    Monster* monster;
    
    if(monsterPicker < 2)
    {
        monster = [SnowmanMonster monster];
    }
    else
    {
        monster = [YetiMonster monster];
    }
    
    // Determine where to spawn the monster along the Y axis
   // monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
    monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, ScalarRandomRange(monster.size.height/2, self.size.height-monster.size.height/2));

    NSValue *value = [NSValue valueWithCGPoint:monster.position];
    
    [self addChild:monster];
    
    // Create the actions
    SKAction * actionMove = [SKAction followPath:[self generateCurvePath:@[value]] asOffset:YES orientToPath:NO duration:5.0];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[actionMove/*, loseAction*/, actionMoveDone]]];
}

-(CGMutablePathRef)generateCurvePath:(NSArray*)coordinates
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, Nil, 0, 0);
    CGPathAddCurveToPoint(path, nil, -100, 100, -200, -100, -560, -50);
    
    return path;
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 3) {
        
        self.lastSpawnTimeInterval = 0;
        
        [self addMonster];

        }

}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void)didSimulatePhysics
{

    if(self.projectile.position.x > self.size.width || -self.projectile.position.y > self.size.height)
    {
        [self.projectile removeFromParent];
    }
    
    if(![self.children containsObject:self.projectile])
    {
        [self spawnProjectile];
    }
}

- (void)monster:(Monster *)monster didCollideWithHero:(Hero *)hero
{
    hero.health--;
    [hero runAction:[self onCollideAction]];
}

- (SKAction *) onCollideAction
{
    SKAction* stutter = [SKAction waitForDuration:.15];
    SKAction* reColor = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1.0 duration:0];
    SKAction* deColor = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.0 duration:0];
    
    return [SKAction sequence:@[reColor,stutter,deColor]];
}


- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(Monster *)monster {
    
    monster.health--;
    NSLog(@"Hit");
    
    [self runAction:[SKAction playSoundFileNamed:@"plop.mp3" waitForCompletion:NO]];
    
//    SKAction* stutter = [SKAction waitForDuration:.15];
//    SKAction* reColor = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1.0 duration:0];
//    SKAction* deColor = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.0 duration:0];
    [monster runAction:[self onCollideAction]];
    
    if (monster.health == 0)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SnowSplosion" ofType:@"sks"];
        SKEmitterNode* explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        [monster addChild:explosion];
        SKAction* wait = [SKAction waitForDuration:.5];
        SKAction* remove = [SKAction removeFromParent];
        SKAction* fadeOut = [SKAction fadeOutWithDuration:.5];
        [monster runAction:[SKAction sequence:@[fadeOut, wait, remove]]];
    
        self.monstersDestroyed++;
    }
    [projectile removeFromParent];
    
    self.monstersDestroyed++;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
 
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
 
    // 2
    if (firstBody.categoryBitMask == projectileCategory &&
        secondBody.categoryBitMask == monsterCategory)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(Monster *) secondBody.node];
    }
}

- (void)setupUI
{
    int barHeight = 35;
    CGSize backgroundSize = CGSizeMake(self.size.width, barHeight);
    
    SKColor *backgroundColor = [SKColor colorWithRed:0 green:0 blue:0.05 alpha:1.0];
    SKSpriteNode *hudBarBackground = [SKSpriteNode spriteNodeWithColor:backgroundColor size:backgroundSize];
    hudBarBackground.position = CGPointMake(0, self.size.height - barHeight);
    hudBarBackground.anchorPoint = CGPointZero;
    [_hudLayerNode addChild:hudBarBackground];
    
    // 1
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
    
    // 2
    scoreLabel.fontSize = 20.0;
    scoreLabel.text = @"Score: 0";
    scoreLabel.name = @"scoreLabel";
    // 3
    scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    // 4
    scoreLabel.position = CGPointMake(self.size.width / 2, self.size.height - scoreLabel.frame.size.height + 3);
    // 5
    [_hudLayerNode addChild:scoreLabel];
    
    _scoreFlashAction = [SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1],[SKAction scaleTo:1.0 duration:0.1]]];
    [scoreLabel runAction:[SKAction repeatAction:_scoreFlashAction count:10]];
    
    // 1
    _healthBar =
    @"==================================================================================";
    float testHealth = 75;
    NSString * actualHealth = [_healthBar substringToIndex:(testHealth / 100 * _healthBar.length)];
    
    // 2
    SKLabelNode *playerHealthBackground =
    [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
    playerHealthBackground.name = @"playerHealthBackground";
    playerHealthBackground.fontColor = [SKColor darkGrayColor];
    playerHealthBackground.fontSize = 10.0f;
    playerHealthBackground.text = _healthBar;
    
    // 3
    playerHealthBackground.horizontalAlignmentMode =  SKLabelHorizontalAlignmentModeLeft;
    playerHealthBackground.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    playerHealthBackground.position =  CGPointMake(0, self.size.height - barHeight + playerHealthBackground.frame.size.height);
    [_hudLayerNode addChild:playerHealthBackground];
    
    // 4
    _playerHealthLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
    _playerHealthLabel.name = @"playerHealth";
    _playerHealthLabel.fontColor = [SKColor whiteColor];
    _playerHealthLabel.fontSize = 10.0f;
    _playerHealthLabel.text = actualHealth;
    _playerHealthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _playerHealthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _playerHealthLabel.position = CGPointMake(0, self.size.height - barHeight +  _playerHealthLabel.frame.size.height);
    [_hudLayerNode addChild:_playerHealthLabel];
    
    _gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
    _gameOverLabel.name = @"gameOver";
    _gameOverLabel.fontSize = 40.0f;
    _gameOverLabel.fontColor = [SKColor whiteColor];
    _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _gameOverLabel.text = @"GAME OVER";
    
    _tapScreenLabel = [SKLabelNode labelNodeWithFontNamed:@"Thirteen Pixel Fonts"];
    _tapScreenLabel.name = @"tapScreen";
    _tapScreenLabel.fontSize = 20.0f;
    _tapScreenLabel.fontColor = [SKColor whiteColor];
    _tapScreenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _tapScreenLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _tapScreenLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
    _tapScreenLabel.text = @"Tap Screen To Restart";
    
    _gameOverPulse = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeOutWithDuration:1.0], [SKAction fadeInWithDuration:1.0]]]];
}

- (void)increaseScoreBy:(float)increment
{
    _score += increment;
    SKLabelNode *scoreLabel = (SKLabelNode*)[_hudLayerNode childNodeWithName:@"scoreLabel"];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0f", _score];
    [scoreLabel removeAllActions];
    [scoreLabel runAction:_scoreFlashAction];
}

@end
