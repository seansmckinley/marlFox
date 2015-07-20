//
//  GameScene.m
//  marlFox
//
//  Created by Sean McKinley on 4/24/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene


-(id)init{
    if((self = [super init])){
        _gameLayer = [GameLayer node];
        [self addChild: _gameLayer z:0];
        [_gameLayer setTag: 123];
        NSLog(@"Init for GameScene done.");
        _menu = [Menu node];
        [self addChild:_menu z:1];
        
    }
    return self;
    
    
}


@end
