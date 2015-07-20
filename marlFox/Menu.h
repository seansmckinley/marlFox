//
//  Menu.h
//  marlFox
//
//  Created by Sean McKinley on 5/6/15.
//  Copyright 2015 Sean McKinley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Menu : CCLayer {
    
}
@property (nonatomic, weak)CCLabelTTF *message;
@property (nonatomic, weak)CCLabelTTF *title;
@property (nonatomic, weak)CCLabelTTF *info;
@property (nonatomic, weak)CCLabelTTF *obj;
@property(nonatomic, weak) CCMenu* portraitMenu;
@end
