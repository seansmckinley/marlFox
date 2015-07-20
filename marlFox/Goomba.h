//
//  Goomba.h
//  marlFox
//
//  Created by Sean McKinley on 4/30/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Goomba : CCSprite {
    
}
@property(nonatomic, assign) BOOL onGround;
@property(nonatomic, assign) CGPoint velocity;
@property(nonatomic, assign) CGPoint desiredPosition;

-(CGRect)cBox;
-(void)update:(ccTime)deltaTime;

@end
