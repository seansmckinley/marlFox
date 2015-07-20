
//
//  GameLevelLayer.m
//  Titlest
//
//  Created by Sean McKinley
//


#import "GameLayer.h"

@interface GameLayer()
{
    CCTMXTiledMap *map;
    Hero  *marle;
    CCTMXLayer *walls;
    BOOL gameOver;
    int numCoins;
    int numScore;
    NSMutableArray *_goombas;
    NSMutableArray *_fireballs;
    NSMutableArray *_coinObjects;
    Frog *frog;
}
@end

@implementation GameLayer

+(CCScene *) scene{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    // 'layer' is an autorelease object.
    GameLayer *layer = [GameLayer node];
    // add layer as a child to scene
    [scene addChild: layer];
    // return the scene
    return scene;
}

-(id) init
{
    //Super class called below
    if( (self=[super init]) ) {
        [self setTouchEnabled:YES];
        _goombas = [[NSMutableArray alloc]init];
        _fireballs = [[NSMutableArray alloc]init];
        _coinObjects =[[NSMutableArray alloc]init];
        CGSize size = [[CCDirector sharedDirector] winSize];
        _coins = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Coins: %d", numCoins] fontName:@"Arial" fontSize:12];
        _score = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"Score: %d", numScore] fontName:@"Arial" fontSize:12];
        _coins.position = ccp(size.width*.05f, size.height* .95f);
        _score.position = ccp(size.width*.05f, size.height* .91f);
        [self addChild:_score z: 10];
        [self addChild:_coins z: 10];
        _spellButton = [CCMenuItemImage itemWithNormalImage:@"epwtb.png" selectedImage:@"epwtb.png" target:self selector:@selector(spellButtonTouched)];
        _spellMenu = [CCMenu menuWithItems:_spellButton, nil];
        _jumpButton = [CCMenuItemImage itemWithNormalImage:@"jump_button.png" selectedImage:@"jump_button.png" target:self selector:@selector(jumpButtonTouched)];
        _jumpMenu = [CCMenu menuWithItems:_jumpButton, nil];
        _leftArrow = [CCMenuItemImage itemWithNormalImage:@"left_arrow.png" selectedImage:@"left_arrow.png" target:self selector:@selector(leftArrowTouched)];
        _rightArrow = [CCMenuItemImage itemWithNormalImage:@"right_arrow.png" selectedImage:@"right_arrow.png" target:self selector:@selector(rightArrowTouched)];
        _arrowMenu = [CCMenu menuWithItems:_leftArrow,_rightArrow, nil];
        _spellMenu.position = ccp(size.width*.23f, size.height*.12f);
        _jumpMenu.position = ccp(size.width*.10f,size.height*.15f);
        _arrowMenu.position = ccp(size.width*.85f, size.height* .15f);
        [_arrowMenu alignItemsHorizontallyWithPadding:40.0];
                map = [[CCTMXTiledMap alloc] initWithTMXFile:@"marl.tmx"];
        [        _spellButton setOpacity:205];
        //make spellButton opaque

        [self addChild: _spellMenu z:15];
        [self addChild: _arrowMenu z:15];
        [self addChild: _jumpMenu z:15];

        //if superclass initializer (CCSprite) works,  then initialize subclass Player
        // paint the sky the same color as the cloud tile from Tiled

        CCLayerColor *blueSky = [[CCLayerColor alloc] initWithColor:ccc4(85,180,255,255)];
        //remember draw order
        [self addChild:blueSky];
        for(CCTMXLayer *child in [map children])[[child texture] setAliasTexParameters];
        [self addChild:map z:9];
        walls = [map layerNamed:@"walls"];
        marle = [[Hero alloc]initWithFile:@"marle.png"];
        marle.position = ccp(50,   110);
        //z order is 15 for player
        [map addChild:marle z:10];
        //grab object groups from tiled map
        CCTMXObjectGroup *objectGroup = [map objectGroupNamed:@"Object"];
        NSAssert(objectGroup != nil, @"tilemap no enemies");
        for(NSMutableDictionary *objProp in objectGroup.objects){
            int x = [[objProp valueForKey:@"x"]integerValue] ;
            int y = [[objProp valueForKey:@"y"]integerValue] ;
            [self addGoombaAtX:(x) y:(y)];
            
        }
        CCTMXObjectGroup *cGroup = [map objectGroupNamed:@"Coin"];
        NSAssert(cGroup != nil, @"tilemap no coins");
        for(NSMutableDictionary *objProp in cGroup.objects){
            int x = [[objProp valueForKey:@"x"]integerValue] ;
            int y = [[objProp valueForKey:@"y"]integerValue] ;
            [self addCoinAtX:(x) y:(y)];
            
        }
        CCTMXObjectGroup *fGroup = [map objectGroupNamed:@"Frog"];
        NSAssert(fGroup != nil, @"tilemap no frog");
        for(NSMutableDictionary *objProp in fGroup.objects){
            int x = [[objProp valueForKey:@"x"]integerValue] ;
            int y = [[objProp valueForKey:@"y"]integerValue] ;
            [self addFrogAtX:(x) y:(y)];
            
        }
        [self schedule:@selector(update:)];
        
    }
    return self;
}

-(void)gameOver:(BOOL)won{
    gameOver = TRUE;
    NSString *gameOverMessage;
    if(won == TRUE) gameOverMessage = @"You win!";
    else gameOverMessage = @"You perished!";
    CCLabelTTF *gameOverLabel = [[CCLabelTTF alloc] initWithString:gameOverMessage fontName:@"Arial" fontSize:30];
    gameOverLabel.position = ccp(270, 200);
    CCMoveBy *transition = [[CCMoveBy alloc]initWithDuration:1.0 position :ccp(0,300)];
    CCMenuItemImage *replay = [[CCMenuItemImage alloc] initWithNormalImage:@"replay.png" selectedImage:@"replay.png" disabledImage:@"replay.png"block:^(id sender){
        [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
    
    }];
    CCMenu *menu = [CCMenu alloc];
    menu = [CCMenu menuWithItems:replay, nil];
    menu.position = ccp(240, -100);
    [self addChild: menu z:10];
    [self addChild: gameOverLabel z:10];
    [menu runAction:transition];
    [self removeChild:_spellMenu cleanup:YES];
    [self removeChild:_arrowMenu cleanup:YES];
    [self removeChild:_jumpMenu cleanup:YES];
}
-(CGPoint) tileCoordinatesFromPosition:(CGPoint)position
//gives coordinate of tile based on position argument
{
    float x = floor(position.x / map.tileSize.width);
    float levelHeight = map.mapSize.height * map.tileSize.height;
    //height coordinate inverted because Cocos2d has origin in bottom left; tilemaps is top left
    float y = floor((levelHeight - position.y) / map.tileSize.height);
    CGPoint coords = ccp(x,y);
    return coords;
}
//reverses coordinate calculation using given tile Coordinates.
-(CGRect) tileRectFromTileCoordinates:(CGPoint) tileCoordinates
{
    float levelHeight = map.mapSize.height * map.tileSize.height;
    //still dealing with coordinate system idiosyncrasies in assignment of origin
    CGPoint origin = ccp(tileCoordinates.x*map.tileSize.width, levelHeight-((tileCoordinates.y+1)*map.tileSize.height));
    CGRect tileRect = CGRectMake(origin.x, origin.y, map.tileSize.width, map.tileSize.height);
    return tileRect;
}
-(void)jumpButtonTouched{
    NSLog(@"Jump");
}
-(void)rightArrowTouched{
    NSLog(@"Right");
}
-(void)leftArrowTouched{
    NSLog(@"Left");
}
-(void)spellButtonTouched{
    NSLog(@"Cast");
    CCSprite *fireball = [CCSprite spriteWithFile:@"fire.png"]; //fireballs are initialized with a fireball art asset
    [_fireballs addObject:fireball]; //add the newly created fireball to our _fireballs array. W need it so we can delete
    //it as a child of the map if it collides before deletion with a goomba
    if (marle.facing ==YES)fireball.position = ccp(marle.position.x+5, marle.position.y); //make marle throw fire!
    else fireball.position = ccp(marle.position.x-5, marle.position.y);
    //Fire moves with a 1 second duration to a specified position.
    id FireMove = [CCMoveBy actionWithDuration:1.0f position:ccp(200.0,-10.0)];
    id negFireMove = [CCMoveBy actionWithDuration:1.0f position:ccp(-200.0,-10.0)];
    CCAction *cleanup = [CCCallBlock actionWithBlock:^{[fireball removeFromParentAndCleanup:YES];}];
    //Create a cleanup action for the fireball.
    [map addChild:fireball z:16];
    if(marle.facing == YES)
        [fireball runAction:[CCSequence actions:FireMove, cleanup,nil]];
    else  [fireball runAction:[CCSequence actions:negFireMove, cleanup,nil]];
}
-(NSArray *) getNearbyTileArray:(CGPoint)position forLayer:(CCTMXLayer *) layer
{
    //this method will return a pointer to an NSArray that contains the information about tiles
    //that surround a specific tile in the CCTMXLayer which is composed in the Tiled map/
    //This method will be very useful in detecting collisions of sprites with ground and walls.
    CGPoint positionOfLayer = [self tileCoordinatesFromPosition:position];
    //declaring gIDs without a call to alloc and init means I can automatically release the array without explicitly
    //calling release. gIDs will contain information on the tiles surrounding the sprite.
    NSMutableArray *gIDs = [NSMutableArray array];
    for(int i = 0; i < 9; i++){
        CGPoint tilePosition; CGRect tileRect;
        int c = i % 3; int r = i/3;
        tilePosition = ccp(positionOfLayer.x+c-1, positionOfLayer.y+r-1);
        tileRect = [self tileRectFromTileCoordinates:tilePosition];
        if(tilePosition.y > map.mapSize.height-1 ){ //if you are out of the bounds of the map, the game is over and you return
            [self gameOver:FALSE];
            return nil;
        }
        int tileGID = [layer tileGIDAt:tilePosition];
        NSDictionary *tileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:tileRect.origin.x], @"x",
                                  [NSNumber numberWithFloat:tileRect.origin.y], @"y",
                                  [NSNumber numberWithInteger:tileGID], @"gID",
                                  [NSValue valueWithCGPoint:tilePosition], @"tilePosition", nil];
        [gIDs addObject:tileDict];
    }

    
    [gIDs removeObjectAtIndex:4]; //remove player tile
    //reorder by insertion to resolve collisions in order of priority
    //because gravity is constantly bringing the sprite down,
    //resolve collision beneath him before moving onto other tiles
    return [NSArray arrayWithObjects:
            [gIDs objectAtIndex:6],
            [gIDs objectAtIndex:1],
            [gIDs objectAtIndex:3],
            [gIDs objectAtIndex:4],
            [gIDs objectAtIndex:0],
            [gIDs objectAtIndex:2],
            [gIDs objectAtIndex:5],
            [gIDs objectAtIndex:7],
                nil];
}

-(void)snapToCenter:(CGPoint) pos{ //center the view on the sprite if he or she begins to move towards screen edge
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    int x = MAX(pos.x, windowSize.width/2);
    int y = MAX(pos.y, windowSize.height/2);
    x = MIN(x, (map.mapSize.width * map.tileSize.width)-windowSize.width/2);
    y = MIN(y, (map.mapSize.height * map.tileSize.height)-windowSize.height/2);
    CGPoint actPos = ccp(-x,-y);
    CGPoint center = ccp(windowSize.width/2, windowSize.height/2);
    CGPoint viewPoint = ccpAdd(center, actPos);
    map.position = viewPoint;
    
}
-(void)addGoombaAtX: (int)x y: (int)y{
    Goomba *goomba = [[Goomba alloc] initWithFile:@"goomba.png"];
    goomba.position = ccp(x,y);
    NSLog(@"Ints x:%d y:%d",x,y);
    [_goombas addObject:goomba];
    [map addChild: goomba z:15 tag:1];
    CCMoveBy *goombaMove = [CCMoveBy actionWithDuration: 3.5f position:ccp(150, 0)];
    CCMoveBy *goombaMoveBack = [CCMoveBy actionWithDuration: 3.5f position:ccp(- 150, 0)];
    id repeat = [CCRepeatForever actionWithAction:[CCSequence actions:goombaMove, goombaMoveBack,nil]];
    [goomba runAction:repeat];
    
}
-(void)addFrogAtX: (int)x y: (int)y{
    frog = [[Frog alloc] initWithFile:@"frog.png"];
    frog.position = ccp(x,y);
    NSLog(@"Ints x:%d y:%d",x,y);
    [map addChild: frog z:15 tag:2];
}
-(void)addCoinAtX: (int)x y: (int)y{
    Coin *acoin = [[Coin alloc] initWithFile:@"1coin.png"];
    acoin.position = ccp(x,y);
    NSLog(@"Ints x:%d y:%d",x,y);
    [_coinObjects addObject:acoin];
    [map addChild: acoin z:15];
}
-(void) update:(ccTime)deltaTime
{
    //update labels every frame.
    [_score setString:[NSString stringWithFormat: @"Score: %d",numScore]];
    [_coins setString:[NSString stringWithFormat: @"Coins: %d",numCoins]];
    //if the games over return
    if(gameOver ==TRUE)return;
    //follow the sprite in the map.
    [self snapToCenter:[marle position]];
    
    if (_rightArrow.isSelected) marle.facing = YES;
    if (_leftArrow.isSelected) marle.facing = NO;
   
    // update frog & marle
    [frog update:deltaTime]; [marle update:deltaTime];
    //frog starts in the air. stop him when he collides.
    [self checkForHeroCollisions:marle]; [self checkForFrogCollisions:frog];
    for(Goomba *g in _goombas){
        //loop over all goombas and call their update methods while making sure they are checked for collisions
        [g update:deltaTime];
        [self checkForGoombaCollisions:g];
    }
    for(Coin *c in _coinObjects) //loop over all Coins and call their update methods while making sure they are checked for collisions; Both goobas and coins spawn in the air
        
    {
        //
        [c update:deltaTime];
        [self checkForCoinCollisions:c];
        // if marle intersects with a coins collision box and the coin is still a child of the map, increment coin count
        if(CGRectIntersectsRect( [marle cBox], [c cBox] ) &&  [ [map children] containsObject:c ]){
            numCoins += 1;
            [map removeChild:(c) cleanup:YES];
        }
    }
    //
    if(CGRectIntersectsRect([marle cBox], [frog cBox] )) [self gameOver:TRUE];
    for(Goomba *g in _goombas){
        if(CGRectIntersectsRect(marle.boundingBox,[g cBox])){
            [self gameOver:FALSE];
            
        }
    }
    NSMutableArray *fire = [[NSMutableArray alloc] init];
    for(CCSprite *f in _fireballs){
        NSMutableArray *goo = [[NSMutableArray alloc] init];
        for(CCSprite *g in _goombas){
            if(CGRectIntersectsRect(CGRectInset(f.boundingBox, 3, 3), CGRectInset(g.boundingBox, 5, 5) )&& [[map children]containsObject:f]){
                numScore+=100;
                [goo addObject:g];
            }
        }
        for(Goomba *g in goo){
            [_goombas removeObject:g];
            [map removeChild:g cleanup:YES];
        }
        if(goo.count >0){
            [fire addObject:f];
        }
    }
    for(CCSprite *f in fire){
        [_fireballs removeObject:f];
        [map removeChild:f cleanup: YES];
    }
    if(!_jumpButton.isSelected) marle.jumping = NO;
    else if(_jumpButton.isSelected == YES && marle.onGround == YES) marle.jumping = YES;
    if(!(_rightArrow.isSelected == YES || _leftArrow.isSelected == YES ))marle.walking = NO;
    else if(_rightArrow.isSelected || _leftArrow.isSelected) marle.walking = YES;

}

-(void) checkForHeroCollisions:(Hero*)j
{
    NSArray *tiles = [self getNearbyTileArray:j.position forLayer:walls];
    if(gameOver == TRUE) return; //if the game is over stop checking for collisions
    j.onGround = NO;
    for(NSDictionary *dict in tiles){ //remember tiles is an NSArray of NSDictionaries
        CGRect jRect = [j cBox];
        int gID = [[dict objectForKey:@"gID"]integerValue];
        if(gID){
            CGFloat x = [[dict objectForKey:@"x"]floatValue]; CGFloat y = [[dict objectForKey:@"y"]floatValue] ;
            CGRect tileRect = CGRectMake(x, y, map.tileSize.width, map.tileSize.height);
            if(CGRectIntersectsRect(jRect,tileRect)) {
                CGRect intersection = CGRectIntersection(jRect, tileRect);
                int index = [tiles indexOfObject:dict];
                if(index == 0){ //tile is below sprite
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y + intersection.size.height );
                    j.velocity= ccp(j.velocity.x, 0.0); j.onGround = YES;
                }else if(index == 1){
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y - intersection.size.height);
                    j.velocity= ccp(j.velocity.x, 0.0);
                }else if(index == 2)
                    j.desiredPosition = ccp(j.desiredPosition.x + intersection.size.width, j.desiredPosition.y);
                else if(index == 3)
                    j.desiredPosition = ccp(j.desiredPosition.x - intersection.size.width, j.desiredPosition.y);
                else{
                    if(intersection.size.width > intersection.size.height){
                        //if the width of the intersection is wider than the intersection is tall, we resolve it by moving
                        //the sprite vertically
                        j.velocity= ccp(j.velocity.x, 0.0);
                        float resolveY;
                        if(index > 5){
                            resolveY = -intersection.size.height; j.onGround = YES;
                        }
                        else resolveY = intersection.size.height;
                        j.desiredPosition = ccp(j.desiredPosition.x,j.desiredPosition.y+resolveY);
                        
                    } else{
                        //if the width of the intersection is taller than the intersection is wide, we resolve it by moving
                        //the sprite horizontally
                        float resolveX;
                        if(index == 4 || index == 6) resolveX = intersection.size.width;
                        else resolveX = -intersection.size.width;
                        
                        j.desiredPosition = ccp(j.desiredPosition.x+resolveX, j.desiredPosition.y);
                    }
                }
            }
        }
    }
    j.position = j.desiredPosition;
}

-(void) checkForFrogCollisions:(Frog*)j
{
    NSArray *tiles = [self getNearbyTileArray:j.position forLayer:walls];
    if(gameOver == TRUE)
    {
        return; //if the game is over stop checking for collisions
            
    }
    j.onGround = NO;
    for(NSDictionary *dict in tiles){ //remember tiles is an NSArray of NSDictionaries
        CGRect jRect = [j cBox];
        int gID = [[dict objectForKey:@"gID"]integerValue];
        if(gID){
            CGFloat x = [[dict objectForKey:@"x"]floatValue]; CGFloat y = [[dict objectForKey:@"y"]floatValue] ;
            CGRect tileRect = CGRectMake(x, y, map.tileSize.width, map.tileSize.height);
            if(CGRectIntersectsRect(jRect,tileRect)) {
                CGRect intersection = CGRectIntersection(jRect, tileRect);
                int index = [tiles indexOfObject:dict];
                if(index == 0){ //tile is below sprite
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y + intersection.size.height );
                    j.velocity= ccp(j.velocity.x, 0.0); j.onGround = YES;
                }else if(index == 1){
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y - intersection.size.height);
                    j.velocity= ccp(j.velocity.x, 0.0);
                }else if(index == 2)
                    j.desiredPosition = ccp(j.desiredPosition.x + intersection.size.width, j.desiredPosition.y);
                else if(index == 3)
                    j.desiredPosition = ccp(j.desiredPosition.x - intersection.size.width, j.desiredPosition.y);
                else{
                    if(intersection.size.width > intersection.size.height){
                        //if the width of the intersection is wider than the intersection is tall, we resolve it by moving
                        //the sprite vertically
                        j.velocity= ccp(j.velocity.x, 0.0);
                        float resolveY;
                        if(index > 5){
                            resolveY = -intersection.size.height; j.onGround = YES;
                        }
                        else resolveY = intersection.size.height;
                        j.desiredPosition = ccp(j.desiredPosition.x,j.desiredPosition.y+resolveY);
                        
                    } else{
                        //if the width of the intersection is taller than the intersection is wide, we resolve it by moving
                        //the sprite horizontally
                        float resolveX;
                        if(index == 4 || index == 6) resolveX = intersection.size.width;
                        else resolveX = -intersection.size.width;
                        
                        j.desiredPosition = ccp(j.desiredPosition.x+resolveX, j.desiredPosition.y);
                    }
                }
            }
        }
    }
    j.position = j.desiredPosition;
}
-(void) checkForGoombaCollisions:(Goomba*)j
{
    NSArray *tiles = [self getNearbyTileArray:j.position forLayer:walls];
    if(gameOver == TRUE)return; //if the game is over stop checking for collisions
    j.onGround = NO;
    for(NSDictionary *dict in tiles){ //remember tiles is an NSArray of NSDictionaries
        CGRect jRect = [j cBox];
        int gID = [ [dict objectForKey:@"gID"] integerValue];
        if(gID){
            //grab x and y coordinates
            CGFloat x = [[dict objectForKey:@"x"]floatValue]; CGFloat y = [[dict objectForKey:@"y"]floatValue] ;
            CGRect tileRect = CGRectMake(x, y, map.tileSize.width, map.tileSize.height);
            if(CGRectIntersectsRect(jRect,tileRect)) {
                CGRect intersection = CGRectIntersection(jRect, tileRect);
                int index = [tiles indexOfObject:dict];
                if(index == 0){ //tile is below sprite
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y + intersection.size.height );
                    j.velocity= ccp(j.velocity.x, 0.0); j.onGround = YES;
                }else if(index == 1){
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y - intersection.size.height);
                    j.velocity= ccp(j.velocity.x, 0.0);
                }
                else if(index == 2)j.desiredPosition = ccp(j.desiredPosition.x + intersection.size.width, j.desiredPosition.y);
                else if(index == 3)j.desiredPosition = ccp(j.desiredPosition.x - intersection.size.width, j.desiredPosition.y);
                else{
                    if(intersection.size.width > intersection.size.height){
                        //if the width of the intersection is wider than the intersection is tall, we resolve it by moving
                        //the sprite vertically
                        j.velocity= ccp(j.velocity.x, 0.0);
                        float resolveY;
                        if(index > 5){
                            resolveY = -intersection.size.height; j.onGround = YES;
                        }
                        else resolveY = intersection.size.height;
                        j.desiredPosition = ccp(j.desiredPosition.x,j.desiredPosition.y+resolveY);
                        
                    } else{
                        //if the width of the intersection is taller than the intersection is wide, we resolve it by moving
                        //the sprite horizontally
                        float resolveX;
                        if(index == 4 || index == 6) resolveX = intersection.size.width;
                        else resolveX = -intersection.size.width;
                        j.desiredPosition = ccp(j.desiredPosition.x+resolveX, j.desiredPosition.y);
                    }
                }
            }
        }
    }
    j.position = j.desiredPosition;
}


-(void) checkForCoinCollisions:(Coin*)j
{
    NSArray *tiles = [self getNearbyTileArray:j.position forLayer:walls];
    if(gameOver == TRUE)
    {
        return; //if the game is over stop checking for collisions
        
    }
    j.onGround = NO;
    for(NSDictionary *dict in tiles){ //remember tiles is an NSArray of NSDictionaries
        CGRect jRect = [j cBox];
        int gID = [[dict objectForKey:@"gID"]integerValue];
        if(gID){
            CGFloat x = [[dict objectForKey:@"x"]floatValue]; CGFloat y = [[dict objectForKey:@"y"]floatValue] ;
            CGRect tileRect = CGRectMake(x, y, map.tileSize.width, map.tileSize.height);
            if(CGRectIntersectsRect(jRect,tileRect)) {
                CGRect intersection = CGRectIntersection(jRect, tileRect);
                int index = [tiles indexOfObject:dict];
                if(index == 0){ //tile is below sprite
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y + intersection.size.height );
                    j.velocity= ccp(j.velocity.x, 0.0); j.onGround = YES;
                }
                else if(index == 1){
                    j.desiredPosition = ccp(j.desiredPosition.x, j.desiredPosition.y - intersection.size.height);
                    j.velocity= ccp(j.velocity.x, 0.0);
                }
                else if(index == 2) j.desiredPosition = ccp(j.desiredPosition.x + intersection.size.width, j.desiredPosition.y);
                else if(index == 3) j.desiredPosition = ccp(j.desiredPosition.x - intersection.size.width, j.desiredPosition.y);
                else{
                    if(intersection.size.width > intersection.size.height){
                        //if the width of the intersection is wider than the intersection is tall, we resolve it by moving
                        //the sprite vertically
                        j.velocity= ccp(j.velocity.x, 0.0);
                        float resolveY;
                        if(index > 5) {resolveY = -intersection.size.height; j.onGround = YES;}
                        else resolveY = intersection.size.height;
                        j.desiredPosition = ccp(j.desiredPosition.x,j.desiredPosition.y+resolveY);
                        
                    } else{
                        //if the width of the intersection is taller than the intersection is wide, we resolve it by moving
                        //the sprite horizontally
                        float resolveX;
                        if(index == 4 || index == 6) resolveX = intersection.size.width;
                        else resolveX = -intersection.size.width;
                        
                        j.desiredPosition = ccp(j.desiredPosition.x+resolveX, j.desiredPosition.y);
                    }
                }
            }
        }
    }
    j.position = j.desiredPosition;
}



@end
