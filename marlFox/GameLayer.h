//
//  GameLayer.m
//  marlFox
//
//  Created by Sean McKinley on 4/23/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import "GameLayer.h"
#import "Hero.h"
#import "Goomba.h"
#import "Frog.h"
#import "Coin.h"
@interface GameLayer : CCLayer{

    
}

@property(nonatomic, weak) CCMenuItemImage* jumpButton;
@property(nonatomic, weak) CCMenuItemImage* leftArrow;
@property(nonatomic, weak) CCMenuItemImage* rightArrow;
@property(nonatomic, weak) CCMenuItemImage* spellButton;

@property(nonatomic, weak) CCMenu* jumpMenu;
@property(nonatomic, weak) CCMenu* arrowMenu;
@property(nonatomic, weak) CCMenu* spellMenu;
@property(nonatomic, weak) CCLabelTTF* coins;
@property(nonatomic, weak) CCLabelTTF* score;





-(void)jumpButtonTouched;
-(void)rightArrowTouched;
-(void)leftArrowTouched;


+(CCScene *) scene;
-(void)update:(ccTime)deltaTime;
-(NSArray *) getNearbyTileArray:(CGPoint)position forLayer:(CCTMXLayer *) layer;
-(void) checkForHeroCollisions:(Hero*)j;
-(void) checkForFrogCollisions:(Frog*)j;
-(void) checkForCoinCollisions:(Coin*)j;
-(void) checkForGoombaCollisions:(Goomba*)j;
// This helper method and the one below are very useful for use of CCTMXLayer objects. Converting from one coordinate system to another is
// needed to locate a particular tile, given their current position.
-(CGRect) tileRectFromTileCoordinates:(CGPoint) tileCoordinates;
    
-(CGPoint) tileCoordinatesFromPosition:(CGPoint)position;


@end