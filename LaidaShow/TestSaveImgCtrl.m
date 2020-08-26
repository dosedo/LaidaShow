//
//  TestSaveImgCtrl.m
//  LaidaShow
//
//  Created by Met on 2020/8/26.
//  Copyright © 2020 deepai. All rights reserved.
//

#import "TestSaveImgCtrl.h"

@interface TestSaveImgCtrl ()

@end

@implementation TestSaveImgCtrl

- (void) image: (UIImage *) image
didFinishSavingWithError: (NSError *) error
contextInfo: (void *) contextInfo{
NSLog(@"呵呵哒");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"work_collection_s"];
    UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
