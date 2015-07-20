//
//  GameScene.h
//  marlFox
//
//  Created by Sean McKinley on 4/24/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


#import "GameLayer.h"
#import "Menu.h"

@interface GameScene : CCScene {
 
}
@property(nonatomic, weak) GameLayer *gameLayer;
@property(nonatomic, weak) Menu *menu;


@end
