//
//  ViewController.m
//  TestAppForVideoCompression
//
//  Created by Fernando on 2/9/15.
//  Copyright (c) 2015 F3rn4nd0. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark event controlls view controller

- (IBAction)touchUpInsideButtonRecordVideo:(id)sender {
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.mediaTypes = @[(id)kUTTypeMovie];
        [self presentViewController:picker animated:NO completion:nil];
    }
}

- (IBAction)touchUpInsideButtonCompressVideo:(id)sender {
    
    NSURL *urlAssertIn = [NSURL URLWithString:textFieldUrl.text];
    
    NSURL *urlOutTemporal = [self getAbsolutePathForTemporalFile];
    
    
    if(![self removeFileFromURL:urlOutTemporal]){
        NSLog(@"Fail removete temporal file");
        return;
    }
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:urlAssertIn options:nil];
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = urlOutTemporal;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    __weak typeof (self) weakSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            [weakSelf replaceAsset:urlOutTemporal urlAssertReplace:urlAssertIn];
        } else {
            NSLog(@"Error Export Session: %@", [exportSession error]);
        }
    }];
    
}

-(void) replaceAsset:(NSURL* )urlInTemporal urlAssertReplace:(NSURL*) urlAssertReplace {
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    __weak typeof (self) weakSelf = self;
    [assetslibrary assetForURL:urlAssertReplace resultBlock:^(ALAsset *asset) {
        if([asset isEditable]) {
            [weakSelf overrideAssert:asset urlInTemporal:urlInTemporal];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error read asset: %@", error);
    }];

}

-(void) overrideAssert:(ALAsset*) asset  urlInTemporal:(NSURL* )urlInTemporal{
    __weak typeof (self) weakSelf = self;
    [asset writeModifiedVideoAtPathToSavedPhotosAlbum:urlInTemporal completionBlock:^(NSURL *assetURL, NSError *error) {
        if(!error) {
            [weakSelf setNewVideoURL:assetURL];
            [weakSelf getSizeOfFile:assetURL];
        }
    }];
}

#pragma mark compression

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset: urlAsset presetName:AVAssetExportPresetHighestQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeMPEG4;
    [session exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(session);
         
     }];
}

#pragma mark delegate UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *recordedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    __weak typeof(self) weakSelf = self;
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:recordedVideoURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:recordedVideoURL completionBlock:^(NSURL *assetURL, NSError *error){
            if(!error) {
                [weakSelf setNewVideoURL:assetURL];
                [weakSelf getSizeOfFile:assetURL];
            }
            
        }];
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark update view controllers info

-(void) setNewVideoURL:(NSURL*) url {
    [textFieldUrl setText:[url absoluteString]];
}

-(void) setSizeOfOrigilaFile:(long) size {
    [labelSizeFile setText:[NSString stringWithFormat:@"%ld kb",size]];
}

-(void) getSizeOfFile:(NSURL*) url {
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        [self setSizeOfOrigilaFile:[asset defaultRepresentation].size];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error read asset: %@", error);
    }];
}

-(NSURL*)getAbsolutePathForTemporalFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths firstObject];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"temporal"];
    NSURL* temporalVideoURL = [NSURL fileURLWithPath:filePath];
    return [temporalVideoURL URLByAppendingPathExtension:@"MOV"];
}


-(BOOL)removeFileFromURL:(NSURL*) urlFile {
    [[NSFileManager defaultManager] removeItemAtURL:urlFile error:nil];
    return true;
}

@end
