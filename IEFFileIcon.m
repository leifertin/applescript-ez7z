//
//  IEFFileIcon.m
//  Test
//  by Ief2
//  Free to use
//

#import "IEFFileIcon.h"


@implementation NSApplication (AppName)
- (void)getImageForPosixPath:(NSString *)myPath placeInImageView:(NSImageView *)imageView {
    [imageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:myPath]];
}
@end