//
//  MyClass2.h
//  BLETest
//
//  Created by TY on 2018/05/08.
//  Copyright © 2018年 yamatakajp. All rights reserved.
//
// ref: https://github.com/kornelski/pngquant/issues/145
#ifndef MyClass2_h
#define MyClass2_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyClass2 : NSObject {
    size_t _bitsPerPixel;
    size_t _bitsPerComponent;
    size_t _width;
    size_t _height;
    size_t _bytesPerRow;

    size_t _speed;
    size_t _gamma;

}

-(NSData *) rgbaFromImage:(UIImage *)image;
-(NSData *) quantizedImageData:(NSData *)data;
@end

#endif /* MyClass2_h */
