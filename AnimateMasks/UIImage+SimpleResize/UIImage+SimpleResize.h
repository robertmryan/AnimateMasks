//  UIImage+SimpleResize.h
//
//  Created by Robert Ryan on 5/19/11.
//
//  This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
//  http://creativecommons.org/licenses/by-sa/4.0/

#import <Foundation/Foundation.h>

/** Image resizing category.
 *
 *  Modified by Robert Ryan on 5/19/11.
 *
 *  Inspired by http://ofcodeandmen.poltras.com/2008/10/30/undocumented-uiimage-resizing/
 *  but adjusted to support AspectFill and AspectFit modes.
 */

@interface UIImage (SimpleResize)

/** Resize the image to be the required size, stretching it as needed.
 *
 * @param newSize      The new size of the image.
 * @param contentMode  The `UIViewContentMode` to be applied when resizing image.
 *                     Either `UIViewContentModeScaleToFill`, `UIViewContentModeScaleAspectFill`, or
 *                     `UIViewContentModeScaleAspectFit`.
 *
 * @return             Return `UIImage` of resized image.
 */

- (UIImage*)imageByScalingToSize:(CGSize)newSize contentMode:(UIViewContentMode)contentMode;

/** Crop the image to be the required size.
 *
 * @param bounds       The bounds to which the new image should be cropped.
 *
 * @return             Cropped `UIImage`.
 */

- (UIImage *)imageByCroppingToBounds:(CGRect)bounds;

/** Resize the image to be the required size, stretching it as needed.
 *
 * @param newSize The new size of the image.
 *
 * @return        Resized `UIImage` of resized image.
 */

- (UIImage*)imageByScalingToFillSize:(CGSize)newSize;

/** Resize the image to fill the rectange of the specified size, preserving the aspect ratio, trimming if needed.
 *
 * @param newSize The new size of the image.
 *
 * @return        Return `UIImage` of resized image.
 */

- (UIImage*)imageByScalingAspectFillSize:(CGSize)newSize;

/** Resize the image to fit within the required size, preserving the aspect ratio, with no trimming taking place.
 *
 * @param newSize The new size of the image.
 *
 * @return        Return `UIImage` of resized image.
 */

- (UIImage*)imageByScalingAspectFitSize:(CGSize)newSize;

@end
