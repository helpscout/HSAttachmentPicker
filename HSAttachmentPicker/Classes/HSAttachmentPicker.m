#import "HSAttachmentPicker.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#import "HSAttachmentPickerPhotoPreviewController.h"

@interface HSAttachmentPicker () <HSAttachmentPickerPhotoPreviewControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation HSAttachmentPicker

-(void)showAttachmentMenu {
    UIAlertController *picker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *showPhotosPermissionSettingsMessage = [NSBundle.mainBundle objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && showPhotosPermissionSettingsMessage != nil) {
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self validatePhotosPermissions:^{
                [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
            }];
        }];
        [picker addAction:takePhotoAction];
    }

    if (showPhotosPermissionSettingsMessage != nil) {
        UIAlertAction *useLastPhotoAction = [UIAlertAction actionWithTitle:@"Use Last Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self validatePhotosPermissions:^{
                [self useLastPhoto];
            }];
        }];
        [picker addAction:useLastPhotoAction];
    }

    if (showPhotosPermissionSettingsMessage != nil) {
        UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self validatePhotosPermissions:^{
                [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            }];
        }];
        [picker addAction:chooseFromLibraryAction];
    }


    UIAlertAction *importFileFromAction = [UIAlertAction actionWithTitle:@"Import File from" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showDocumentPicker];
    }];
    [picker addAction:importFileFromAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [picker addAction:cancelAction];

    [_delegate attachmentPickerMenu:self showController:picker completion:nil];
}

#pragma mark - import file
-(void)showDocumentPicker {
    @try {
        NSArray *documentTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeItem, nil];
        UIDocumentMenuViewController *documentMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
        documentMenu.delegate = self;
        [_delegate attachmentPickerMenu:self showController:documentMenu completion:nil];
    }
    @catch (NSException *exception) {
        [_delegate attachmentPickerMenu:self showErrorMessage:@"This application is not entitled to access iCloud"];
    }
}

#pragma mark - use last photo
-(void)useLastPhoto {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:true]];
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if (fetchResult.count == 0) {
        [_delegate attachmentPickerMenu:self showErrorMessage:@"There doesn't seem to be a photo taken yet."];
        return;
    }
    [self uploadPhoto:fetchResult.lastObject];
}

#pragma mark - permissions check for photos
-(void)validatePhotosPermissions:(void(^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized) {
            completion();
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    [self showPhotosPermissionSettingsMessage];
                } else {
                    completion();
                }
            }];
        }
    });
}

-(void)showPhotosPermissionSettingsMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *accessDescription = [NSBundle.mainBundle objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self.delegate attachmentPickerMenu:self showController:alert completion:nil];
    });
}

#pragma mark - open image picker for camera or photo library
-(void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = false;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie, nil];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
    imagePicker.sourceType = sourceType;
    [_delegate attachmentPickerMenu:self showController:imagePicker completion:^{
        UIApplication.sharedApplication.statusBarHidden = true;
    }];
}

#pragma mark - save from camera
- (void)saveVideoFromCamera:(NSDictionary<NSString *,id> * _Nonnull)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    NSMutableDictionary *placeholder = [[NSMutableDictionary alloc]init];
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        placeholder[@"asset"] = request.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSData *contents = [NSFileManager.defaultManager contentsAtPath:url.path];
            NSString *fileName = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
            [self.delegate attachmentPickerMenu:self upload:contents filename:fileName image:nil];
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"Unable to save video: %@", error.localizedDescription];
            [self.delegate attachmentPickerMenu:self showErrorMessage:errorMessage];
        }
    }];
}

- (void)savePhotoFromCamera:(NSDictionary<NSString *,id> * _Nonnull)info {
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self useLastPhoto];
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"Unable to save photo: %@", error.localizedDescription];
            [self.delegate attachmentPickerMenu:self showErrorMessage:errorMessage];
        }
    }];
}

#pragma mark - upload operations
-(void)uploadSavedMedia:(NSDictionary<NSString *,id> *)info {
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithALAssetURLs:@[info[UIImagePickerControllerReferenceURL]] options:nil];
    for (PHAsset* asset in assets) {
        switch (asset.mediaType) {
            case PHAssetMediaTypeImage:
                [self uploadPhoto:asset];
                break;

            case PHAssetMediaTypeVideo:
                [self uploadMovie:info];
                break;

            default:
                [_delegate attachmentPickerMenu:self showErrorMessage:@"Selected media type is unsupported"];
                break;
        }
    }
}

-(void)uploadMovie:(NSDictionary<NSString *,id> *)info {
    NSURL *fileURL = info[UIImagePickerControllerMediaURL];
    NSData *videoData = [NSFileManager.defaultManager contentsAtPath:fileURL.path];
    NSString *fileName = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
    [_delegate attachmentPickerMenu:self upload:videoData filename:fileName image:nil];
}

-(void)uploadPhoto:(PHAsset*)photo {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    CGSize targetSize = photo.pixelWidth > photo.pixelHeight ? CGSizeMake(1024, 768) : CGSizeMake(768, 1024);
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.synchronous = true;
    [PHImageManager.defaultManager requestImageForAsset:photo targetSize:targetSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        NSData *data = UIImageJPEGRepresentation(result, 0.5);
        NSString *filename = [photo valueForKey:@"filename"] ?: @"photo.jpg";
        [self.delegate attachmentPickerMenu:self upload:data filename:filename.lowercaseString image:result];
    }];
}

#pragma mark - HSAttachmentPickerPhotoPreviewControllerDelegate
- (void)photoPreview:(HSAttachmentPickerPhotoPreviewController * _Nonnull)photoPreview usePhoto:(NSDictionary<NSString *,id> * _Nonnull)info {
    [self uploadSavedMedia:info];
}

#pragma mark - UIDocumentMenuDelegate
-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    documentPicker.delegate = self;
    [_delegate attachmentPickerMenu:self showController:documentPicker completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [_delegate attachmentPickerMenu:self upload:[NSData dataWithContentsOfURL:url] filename:url.path.lastPathComponent image:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) {
            [picker dismissViewControllerAnimated:true completion:nil];
            [self uploadSavedMedia:info];
        } else {
            HSAttachmentPickerPhotoPreviewController *previewController = [[HSAttachmentPickerPhotoPreviewController alloc] init];
            previewController.delegate = self;
            previewController.info = info;
            [picker pushViewController:previewController animated:true];
        }
        return;
    }
    [picker dismissViewControllerAnimated:true completion:nil];
    if (info[UIImagePickerControllerMediaType] == (NSString*)kUTTypeMovie) {
        [self saveVideoFromCamera:info];
    } else {
        [self savePhotoFromCamera:info];
    }
}

@end
