//
//  ViewController.h
//  TestAppForVideoCompression
//
//  Created by Fernando on 2/9/15.
//  Copyright (c) 2015 F3rn4nd0. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate> {
    
    __weak IBOutlet UITextField *textFieldUrl;
    __weak IBOutlet UILabel *labelSizeFile;
    
}


@end

