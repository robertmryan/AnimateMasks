//  UIImage+SimpleResize.m
//
//  Created by Robert Ryan on 5/19/11.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

#import "UIImage+SimpleResize.h"

@implementation UIImage (SimpleResize)

- (UIImage*)imageByScalingToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode
{
    if (contentMode == UIViewContentModeScaleToFill) {
        return [self imageByScalingToFillSize:newSize];
    }

    if ((contentMode == UIViewContentModeScaleAspectFill) ||
        (contentMode == UIViewContentModeScaleAspectFit)) {

        CGFloat horizontalRatio   = self.size.width  / newSize.width;
        CGFloat verticalRatio     = self.size.height / newSize.height;
        CGFloat ratio;
        
        if (contentMode == UIViewContentModeScaleAspectFill)
            ratio = MIN(horizontalRatio, verticalRatio);
        else
            ratio = MAX(horizontalRatio, verticalRatio);
        
        CGSize  sizeForAspectScale = CGSizeMake(self.size.width / ratio, self.size.height / ratio);
        
        UIImage *image = [self imageByScalingToFillSize:sizeForAspectScale];
        
        // if we're doing aspect fill, then the image still needs to be cropped
        
        if (contentMode == UIViewContentModeScaleAspectFill) {
            CGRect  subRect = CGRectMake(floor((sizeForAspectScale.width - newSize.width) / 2.0),
                                         floor((sizeForAspectScale.height - newSize.height) / 2.0),
                                         newSize.width,
                                         newSize.height);
            image = [image imageByCroppingToBounds:subRect];
        }
        
        return image;
    }
    
    return nil;
}

- (UIImage *)imageByCroppingToBounds:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage*)imageByScalingToFillSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)imageByScalingAspectFillSize:(CGSize)newSize
{
    return [self imageByScalingToSize:newSize contentMode:UIViewContentModeScaleAspectFill];
}

- (UIImage*)imageByScalingAspectFitSize:(CGSize)newSize
{
    return [self imageByScalingToSize:newSize contentMode:UIViewContentModeScaleAspectFit];
}

@end
