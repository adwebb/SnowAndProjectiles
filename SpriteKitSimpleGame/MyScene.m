//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

//static NSString * const movableNodeName = @"movable";

#import "MyScene.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "SnowmanMonster.h"
#import "YetiMonster.h"
#import "Hero.h"
#import "Projectile.h"
#import "SnowballProjectile.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t heroCategory           =  0x11;

@interface MyScene () <SKPhysicsContactDelegate, UIGestureRecognizerDelegate>
{
    Hero* hero;
    
    UIPanGestureRecognizer* panGestureRecognizer;
    CGPoint projectileSpawnPoint;
    
    SKLabelNode *_playerHealthLabel;
    NSString    *_healthBar;
    SKAction    *_scoreFlashAction;
    SKAction    *_gameOverPulse;
    SKLabelNode *_gameOverLabel;
    SKNode      *_hudLayerNode;
    SKLabelNode *_tapScreenLabel;
    SKLabelNode* currencyLabel;
    
    CGFloat _score;
    SKLabelNode *scoreLabel;
    int _gameState;
}

@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
@property (nonatomic) SKSpriteNode* projectile;
@property (nonatomic) int currency;

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
{
    Projectile* chosenProjectile;
    SKSpriteNode* regularProjectile;
    SKSpriteNode* freezeProjectile;
    SKSpriteNode* fireProjectile;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        _score = 0;
        
        // Loading the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.jpg"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        _hudLayerNode = [SKNode node];
        [self addChild:_hudLayerNode];
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        hero = [Hero spawnHero];
        hero.position = CGPointMake(hero.size.width*2, self.frame.size.height*2/5);
        [self addChild:hero];
        
        projectileSpawnPoint = CGPointMake(hero.size.width*2, self.frame.size.height*2/5+hero.size.height/2);
        
        NSString *snowPath = [[NSBundle mainBundle] pathForResource:@"backgroundSnow" ofType:@"sks"];
        SKEmitterNode* snowEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:snowPath];
        snowEmitter.position = CGPointMake(self.frame.size.width/2, self.frame.size.height+10);
        [_background addChild:snowEmitter];
        
        [self spawnProjectile];
        
        self.physicsWorld.gravity = CGVectorMake(0,-5);
        self.physicsWorld.contactDelegate = self;
        self.currency = 0;
        
        [self setupUI];
        [self setupProjectileButtons];
    }
    return self;
}

- (void)spawnProjectile
{
    chosenProjectile = [SnowballProjectile snowballProjectile];
    chosenProjectile.position = projectileSpawnPoint;
    [self addChild:chosenProjectile];
}

- (void)didMoveToView:(SKView *)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.delegate = self;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	if(chosenProjectile.alpha == 1 && chosenProjectile.physicsBody.affectedByGravity == NO)
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
                
                CGPoint location = chosenProjectile.position;
                CGPoint offset = rwSub(location, projectileSpawnPoint);
                
                // Bail out if you are shooting down or backwards
                if (offset.x >= 0) return;
                
                // Get the direction of where to shoot
                CGPoint direction = rwNormalize(offset);
                CGPoint launchDirection = rwInvert(direction);
                float force = rwLength(offset);
                CGPoint multiplied = rwMult(launchDirection, force/3);
                CGVector launcher = CGVectorMake(multiplied.x, multiplied.y);
                
                chosenProjectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:chosenProjectile.size.width/2];
                chosenProjectile.physicsBody.dynamic = YES;
                chosenProjectile.physicsBody.categoryBitMask = projectileCategory;
                chosenProjectile.physicsBody.contactTestBitMask = monsterCategory;
                chosenProjectile.physicsBody.collisionBitMask = 0;
                chosenProjectile.physicsBody.usesPreciseCollisionDetection = YES;
                
                chosenProjectile.physicsBody.affectedByGravity = YES;
                [chosenProjectile.physicsBody applyImpulse:launcher];
            }
        }
    }
}

- (void)panForTranslation:(CGPoint)translation fromStartPoint:(CGPoint)point
{
    if([self isWithinSlingshotDragArea:point])
    {
        CGPoint position = chosenProjectile.position;
        CGPoint newPosition = CGPointMake(position.x + translation.x, position.y + translation.y);
        if([self isWithinSlingshotDragArea:newPosition]) {
            [chosenProjectile setPosition:newPosition];
        }
    }
}

- (void)selectNodeForTouch:(CGPoint)touchLocation
{
    if([self isWithinSlingshotDragArea:touchLocation])
    {
        SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-4.0f) duration:0.1],
                                                  [SKAction rotateByAngle:0.0 duration:0.1],
                                                  [SKAction rotateByAngle:degToRad(4.0f) duration:0.1]]];

    [chosenProjectile runAction:[SKAction repeatActionForever:sequence]];
        _selectedNode = chosenProjectile;
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

- (void)addMonster
{
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
    monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, self.frame.size.height/2);
    
    NSValue *value = [NSValue valueWithCGPoint:monster.position];
    
    [self addChild:monster];
    
    // Create the actions
    SKAction * actionMove = [SKAction followPath:[self generateCurvePath:@[value]] asOffset:YES orientToPath:NO duration:5.0];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [monster runAction:[SKAction sequence:@[actionMove/*, loseAction*/, actionMoveDone]]withKey:@"path"];
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
    
    if (self.lastSpawnTimeInterval > 3)
    {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1)
    { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    switch (_gameState) {
        case GameRunning:
        
            // Update the healthbar color and length based on the...urm...players health :)
            _playerHealthLabel.text = [_healthBar substringToIndex:(hero.health / 10 * _healthBar.length)];
            currencyLabel.text = [NSString stringWithFormat:@"%d",self.currency];
            // If the players health has dropped to <= 0 then set the game state to game over
            if (hero.health <= 0) {
                _gameState = GameOver;
            }
            else
            {
                [self updateWithTimeSinceLastUpdate:timeSinceLast];
            }
            
            break;
        case GameOver:
        {
            // If the game over message has not been added to the scene yet then add it
            if (!_gameOverLabel.parent)
            {
                [hero removeFromParent];
                
                [_hudLayerNode addChild:_gameOverLabel];
                [_hudLayerNode addChild:_tapScreenLabel];
                [_tapScreenLabel runAction:_gameOverPulse];
                
                SKColor *newColor = [SKColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0];
                _gameOverLabel.fontColor = newColor;
            }
            break;
        }
        default:
            NSLog(@"default case");
            break;
    }
}

-(void)didSimulatePhysics
{
    if(chosenProjectile.position.x > self.size.width || -chosenProjectile.position.y > self.size.height)
    {
        [chosenProjectile removeFromParent];
    }
    
    if(![self.children containsObject:chosenProjectile])
    {
        [self spawnProjectile];
    }
}

- (void)setupProjectileButtons
{
    regularProjectile = [SKSpriteNode spriteNodeWithImageNamed:@"green"];
    regularProjectile.position = CGPointMake(self.frame.size.height/8, self.frame.size.width/15);
    [self addChild:regularProjectile];
    
    freezeProjectile = [SKSpriteNode spriteNodeWithImageNamed:@"blue"];
    freezeProjectile.position = CGPointMake(self.frame.size.height/3.2, self.frame.size.width/15);
    [self addChild:freezeProjectile];
   
    fireProjectile = [SKSpriteNode spriteNodeWithImageNamed:@"red"];
    fireProjectile.position = CGPointMake(self.frame.size.height/2, self.frame.size.width/15);
    [self addChild:fireProjectile];
}

- (void)monster:(Monster*)monster didCollideWithHero:(Hero*)ourHero
{
    ourHero.health--;
    NSLog(@"ouch! I have %f life!", ourHero.health);
    [hero runAction:[self onHitColoration]];
    [monster removeFromParent];
}
    
- (SKAction *)onHitColoration
{
    SKAction* stutter = [SKAction waitForDuration:.15];
    SKAction* reColor = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:1.0 duration:0];
    SKAction* deColor = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.0 duration:0];
    
    return [SKAction sequence:@[reColor,stutter,deColor]];
}

- (void)projectile:(Projectile *)firedProjectile didCollideWithMonster:(Monster *)monster
{
    monster.health--;
    NSLog(@"Hit");
    _score = _score + 10;
    NSLog(@"score %f", _score);

    scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0f", _score];
    
    [self runAction:[SKAction playSoundFileNamed:@"plop.mp3" waitForCompletion:NO]];
    
    [monster runAction:[self onHitColoration]];
    
    if (monster.health == 0)
    {
        [self killedMonster:monster];
    }
    [firedProjectile removeFromParent];
    
    self.monstersDestroyed++;
}

-(void)killedMonster:(Monster*)monster
{
    monster.physicsBody.contactTestBitMask = 0x0;
    monster.physicsBody.categoryBitMask = 0x0;
    [monster removeActionForKey:@"path"];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SnowSplosion" ofType:@"sks"];
    SKEmitterNode* explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [monster addChild:explosion];
   
    SKAction* wait = [SKAction waitForDuration:.5];
    SKAction* remove = [SKAction removeFromParent];
    SKAction* fadeOut = [SKAction fadeOutWithDuration:.5];
    [monster runAction:[SKAction sequence:@[fadeOut, wait, remove]]];
    
    SKNode* coinNode = [SKNode new];
    [self addChild:coinNode];
    
    SKSpriteNode* coin = [SKSpriteNode spriteNodeWithImageNamed:@"coin"];
    coin.position = CGPointMake(monster.position.x, monster.position.y+monster.size.height/2);
    [coinNode addChild:coin];
    
    SKLabelNode* gold = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
    gold.text = [NSString stringWithFormat:@"%d",monster.goldValue];
    gold.fontSize = 15.0;
    gold.fontColor = [UIColor colorWithRed:1 green:192/255.0 blue:0 alpha:1];
    gold.position = CGPointMake(coin.position.x+coin.size.width*1.2, coin.position.y-5);
    [coinNode addChild:gold];
    
    [coinNode runAction:[SKAction waitForDuration:.4] completion:^{
        [coinNode removeFromParent];
    }];
    
    self.currency += monster.goldValue;
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
    
    if (firstBody.categoryBitMask == monsterCategory && secondBody.categoryBitMask == heroCategory)
    {
        [self monster:(Monster*)firstBody.node didCollideWithHero:(Hero*)secondBody.node];
    }
    else if (firstBody.categoryBitMask == projectileCategory && secondBody.categoryBitMask == monsterCategory)
    {
        [self projectile:(Projectile *) firstBody.node didCollideWithMonster:(Monster *) secondBody.node];
    }
}

- (void)setupUI
{
        int barHeight = 35;
        CGSize backgroundSize = CGSizeMake(self.size.width, barHeight);
        
        SKColor *backgroundColor = [SKColor colorWithRed:0 green:0 blue:0.05 alpha:.5];
        SKSpriteNode *hudBarBackground = [SKSpriteNode spriteNodeWithColor:backgroundColor size:backgroundSize];
        hudBarBackground.position = CGPointMake(0, self.size.height - barHeight);
        hudBarBackground.anchorPoint = CGPointZero;
        [_hudLayerNode addChild:hudBarBackground];
        
        // 1
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        
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
        
        // 1
        _healthBar = @"❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️";
        float testHealth = 7;
        NSString * actualHealth = [_healthBar substringToIndex:(testHealth / 10 * _healthBar.length)];
        
        // 2
        SKLabelNode *playerHealthBackground = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        playerHealthBackground.name = @"playerHealthBackground";
        playerHealthBackground.color = [SKColor darkTextColor];
        playerHealthBackground.colorBlendFactor = .5;
        playerHealthBackground.fontSize = 15.0f;
        playerHealthBackground.text = _healthBar;
        
        currencyLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        SKSpriteNode* coinStack = [SKSpriteNode spriteNodeWithImageNamed:@"stack"];
        coinStack.position = CGPointMake(self.size.width-coinStack.size.width-50, self.size.height-barHeight/2);
        currencyLabel.position = CGPointMake(coinStack.position.x-coinStack.size.width, coinStack.position.y);
        currencyLabel.fontSize = 20;
        currencyLabel.text = @"0";
        currencyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        currencyLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [_hudLayerNode addChild:currencyLabel];
        [_hudLayerNode addChild:coinStack];
        
        
        // 3
        playerHealthBackground.horizontalAlignmentMode =  SKLabelHorizontalAlignmentModeLeft;
        playerHealthBackground.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        playerHealthBackground.position =  CGPointMake(0, self.size.height - barHeight/4);
        [_hudLayerNode addChild:playerHealthBackground];
        
        // 4
        _playerHealthLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
        _playerHealthLabel.name = @"playerHealth";
        _playerHealthLabel.fontColor = [SKColor whiteColor];
        _playerHealthLabel.fontSize = 15.0f;
        _playerHealthLabel.text = actualHealth;
        _playerHealthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _playerHealthLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _playerHealthLabel.position = CGPointMake(0, self.size.height - barHeight/4);
        [_hudLayerNode addChild:_playerHealthLabel];
        
        _gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _gameOverLabel.name = @"gameOver";
        _gameOverLabel.fontSize = 40.0f;
        _gameOverLabel.fontColor = [SKColor whiteColor];
        _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        _gameOverLabel.text = @"GAME OVER";
        
        _tapScreenLabel = [SKLabelNode labelNodeWithFontNamed:@"chalkduster"];
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
        scoreLabel = (SKLabelNode*)[_hudLayerNode childNodeWithName:@"scoreLabel"];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %1.0f", _score];
        [scoreLabel removeAllActions];
        [scoreLabel runAction:_scoreFlashAction];
}

@end
