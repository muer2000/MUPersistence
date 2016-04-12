//
//  BSImageItem.h
//  MUPersistenceExample
//
//  Created by Muer on 16/4/12.
//  Copyright © 2016年 Muer. All rights reserved.
//

#import "MUPersistent.h"
#import <UIKit/UIKit.h>

@interface BSImageItem : MUPersistent

// implementation keyMapping

@property (nonatomic, strong) NSString *picURL;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;

@end
