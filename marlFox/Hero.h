//
//  Hero.h
//  marlFox
//
//  Created by Sean McKinley on 4/23/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Hero : CCSprite {
    
    
}
@property(nonatomic, assign) BOOL onGround;
@property(nonatomic, assign) CGPoint velocity;
@property(nonatomic, assign) CGPoint desiredPosition;
//part 2

@property(nonatomic, assign) BOOL walking;
@property(nonatomic, assign) BOOL jumping;
@property(nonatomic, assign) BOOL facing;


-(CGRect)cBox;
-(void)update:(ccTime)deltaTime;

@end
