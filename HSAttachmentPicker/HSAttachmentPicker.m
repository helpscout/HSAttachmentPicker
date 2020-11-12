#import "HSAttachmentPicker.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#import "HSAttachmentPickerPhotoPreviewController.h"

@interface HSAttachmentPicker () <HSAttachmentPickerPhotoPreviewControllerDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate>

@property(nonatomic) HSAttachmentPicker *selfReference;

@end

@implementation HSAttachmentPicker

static NSString *const kBeaconUTTypeLivePhotoBundle = @"com.apple.live-photo-bundle";

- (instancetype)init {
    self = [super init];
    if (self) {
        self.preferredVideoQuality = UIImagePickerControllerQualityTypeMedium;
    }
    return self;
}

- (void)showAttachmentMenu {
    self.selfReference = self;
    UIAlertController *picker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *showPhotosPermissionSettingsMessage = [NSBundle.mainBundle objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && showPhotosPermissionSettingsMessage != nil) {
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:[self translateString:@"Take Photo"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (@available(iOS 14.0, *)) {
                [self validatePhotosPermissionsWithAccessLevel:PHAccessLevelAddOnly completion:^{
                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                }];
            } else {
                [self validatePhotosPermissions:^{
                    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                }];
            }
        }];
        [picker addAction:takePhotoAction];
    }

    if (showPhotosPermissionSettingsMessage != nil) {
        if (@available(iOS 14.0, *)) {
            // the app already has access to the Photo Library so we're safe to add `Use Last Photo` here
            if ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] == PHAuthorizationStatusAuthorized) {
                UIAlertAction *useLastPhotoAction = [UIAlertAction actionWithTitle:[self translateString:@"Use Last Photo"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self useLastPhoto];
                }];
                [picker addAction:useLastPhotoAction];
            }
        } else {
            UIAlertAction *useLastPhotoAction = [UIAlertAction actionWithTitle:[self translateString:@"Use Last Photo"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self validatePhotosPermissions:^{
                    [self useLastPhoto];
                }];
            }];
            [picker addAction:useLastPhotoAction];
        }
    }

    if (showPhotosPermissionSettingsMessage != nil) {
        UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:[self translateString:@"Choose from Library"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (@available(iOS 14, *)) {
                // don't request access to users photo library since we don't need it with PHPicker
                [self showPhotoPicker];
            } else {
                [self validatePhotosPermissions:^{
                    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                }];
            }
        }];
        [picker addAction:chooseFromLibraryAction];
    }

    UIAlertAction *importFileFromAction = [UIAlertAction actionWithTitle:[self translateString:@"Import File from"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showDocumentPicker];
    }];
    [picker addAction:importFileFromAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self translateString:@"Cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissed];
    }];
    [picker addAction:cancelAction];

    [self.delegate attachmentPickerMenu:self showController:picker completion:nil];
}

#pragma mark - import file
- (void)showDocumentPicker {
    @try {
        NSArray<NSString *> *documentTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeItem, nil];
        UIDocumentPickerViewController *documentMenu = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
        documentMenu.delegate = self;
        [self.delegate attachmentPickerMenu:self showController:documentMenu completion:nil];
    }
    @catch (NSException *exception) {
        [self showError:[self translateString:@"This application is not entitled to access iCloud"]];
    }
}

#pragma mark - use last photo
- (void)useLastPhoto {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if (fetchResult.count == 0) {
        [self showError:[self translateString:@"There doesn't seem to be a photo taken yet."]];
        return;
    }
    [self uploadPhoto:fetchResult.lastObject];
}

#pragma mark - permissions check for photos
- (void)validatePhotosPermissions:(void(^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized) {
            completion();
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    [self showPhotosPermissionSettingsMessage];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion();
                    });
                }
            }];
        }
    });
}

- (void)validatePhotosPermissionsWithAccessLevel:(PHAccessLevel)accessLevel completion:(void(^)(void))completion API_AVAILABLE(ios(14)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([PHPhotoLibrary authorizationStatusForAccessLevel:accessLevel] == PHAuthorizationStatusAuthorized) {
            completion();
        } else {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:accessLevel handler:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    [self showPhotosPermissionSettingsMessage];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion();
                    });
                }
            }];
        }
    });
}

- (void)showPhotosPermissionSettingsMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *accessDescription = [NSBundle.mainBundle objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:accessDescription message:[self translateString:@"To give permissions tap on 'Change Settings' button"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self translateString:@"Cancel"] style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[self translateString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self.delegate attachmentPickerMenu:self showController:alert completion:nil];
    });
}

#pragma mark - open image picker for camera or photo library
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie, nil];
    imagePicker.videoQuality = self.preferredVideoQuality;
    imagePicker.sourceType = sourceType;
    [self.delegate attachmentPickerMenu:self showController:imagePicker completion:^{
        UIApplication.sharedApplication.statusBarHidden = YES;
    }];
}

- (void)showPhotoPicker API_AVAILABLE(ios(14)) {
    PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
    configuration.filter = [PHPickerFilter anyFilterMatchingSubfilters:@[PHPickerFilter.imagesFilter, PHPickerFilter.livePhotosFilter, PHPickerFilter.videosFilter]];

    PHPickerViewController *imagePicker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
    imagePicker.delegate = self;

    [self.delegate attachmentPickerMenu:self showController:imagePicker completion:nil];
}

#pragma mark - save from camera
- (void)saveVideoFromCamera:(NSDictionary<UIImagePickerControllerInfoKey, id> * _Nonnull)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    NSMutableDictionary *placeholder = [[NSMutableDictionary alloc] init];
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        placeholder[@"asset"] = request.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSData *contents = [NSFileManager.defaultManager contentsAtPath:url.path];
                NSString *filename = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
                [self upload:contents filename:filename image:nil];
            } else {
                NSString *errorMessage = [NSString stringWithFormat:[self translateString:@"Unable to save video: %@"], error.localizedDescription];
                [self showError:errorMessage];
            }
        });
    }];
}

- (void)savePhotoFromCamera:(NSDictionary<NSString *,id> * _Nonnull)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                NSString *filename = [NSString stringWithFormat:@"%@.jpg", NSUUID.UUID.UUIDString];
                [self upload:data filename:filename image:image];
            } else {
                NSString *errorMessage = [NSString stringWithFormat:[self translateString:@"Unable to save photo: %@"], error.localizedDescription];
                [self showError:errorMessage];
            }
        });
    }];
}

- (NSString *)translateString:(NSString *)key {
    NSBundle *bundle = self.translationsBundle ? self.translationsBundle : NSBundle.mainBundle;
    return [bundle localizedStringForKey:key value:nil table:self.translationTable];
}

- (void)upload:(NSData *)data filename:(NSString *)filename image:(UIImage *)image {
    [self.delegate attachmentPickerMenu:self upload:data filename:filename image:image];
    [self dismissed];
}

- (void)dismissed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(attachmentPickerMenuDismissed:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate attachmentPickerMenuDismissed:self];
            self.selfReference = nil;
        });
    } else {
        self.selfReference = nil;
    }
}

- (void)showError:(NSString *)errorMessage {
    [self.delegate attachmentPickerMenu:self showErrorMessage:errorMessage];
    [self dismissed];
}

#pragma mark - upload operations
- (void)uploadSavedMedia:(NSDictionary<UIImagePickerControllerInfoKey, id> * _Nonnull)info {
    PHAsset *asset = info[UIImagePickerControllerPHAsset];
    switch (asset.mediaType) {
        case PHAssetMediaTypeImage:
            [self uploadPhoto:asset];
            break;

        case PHAssetMediaTypeVideo:
            [self uploadMovie:info];
            break;

        default:
            [self showError:[self translateString:@"Selected media type is unsupported"]];
            break;
    }
}

- (void)uploadMovie:(NSDictionary<UIImagePickerControllerInfoKey, id> * _Nonnull)info {
    NSURL *fileURL = info[UIImagePickerControllerMediaURL];
    NSData *videoData = [NSFileManager.defaultManager contentsAtPath:fileURL.path];
    NSString *filename = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
    [self upload:videoData filename:filename image:nil];
}

- (void)uploadPhoto:(PHAsset *)photo {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.synchronous = YES;
    if (@available(iOS 13.0, *)) {
        [PHImageManager.defaultManager requestImageDataAndOrientationForAsset:photo options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = [UIImage imageWithData:imageData];
            NSString *filename = [photo valueForKey:@"filename"] ?: @"photo.jpg";
            [self upload:imageData filename:filename.lowercaseString image:image];
        }];
    } else {
        [PHImageManager.defaultManager requestImageDataForAsset:photo options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = [UIImage imageWithData:imageData];
            NSString *filename = [photo valueForKey:@"filename"] ?: @"photo.jpg";
            [self upload:imageData filename:filename.lowercaseString image:image];
        }];
    }
}

#pragma mark - HSAttachmentPickerPhotoPreviewControllerDelegate
- (void)photoPreview:(HSAttachmentPickerPhotoPreviewController * _Nonnull)photoPreview usePhoto:(NSDictionary<UIImagePickerControllerInfoKey, id> * _Nonnull)info {
    [self uploadSavedMedia:info];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = [urls firstObject];
    if (url) {
        [self upload:[NSData dataWithContentsOfURL:url] filename:url.path.lastPathComponent image:nil];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self dismissed];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    if (picker.sourceType != UIImagePickerControllerSourceTypeCamera) {
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            [self uploadSavedMedia:info];
        } else {
            HSAttachmentPickerPhotoPreviewController *previewController = [[HSAttachmentPickerPhotoPreviewController alloc] init];
            previewController.translationsBundle = self.translationsBundle;
            previewController.translationTable = self.translationTable;
            previewController.delegate = self;
            previewController.info = info;
            [picker pushViewController:previewController animated:YES];
        }
        return;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (info[UIImagePickerControllerMediaType] == (NSString*)kUTTypeMovie) {
        [self saveVideoFromCamera:info];
    } else {
        [self savePhotoFromCamera:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissed];
    }];
}

#pragma  mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results  API_AVAILABLE(ios(14)) {
    [picker dismissViewControllerAnimated:YES completion:nil];

    PHPickerResult *result = [results firstObject];

    NSItemProvider *itemProvider = result.itemProvider;
    NSArray<NSString *> *registeredIdentifiers = itemProvider.registeredTypeIdentifiers;
    NSString *typeIdentifier = [registeredIdentifiers firstObject];
    if ([itemProvider canLoadObjectOfClass:[UIImage class]]) {
        if (!typeIdentifier || [typeIdentifier isEqualToString:kBeaconUTTypeLivePhotoBundle]) {
            typeIdentifier = (NSString *)kUTTypeJPEG;
        }
        [itemProvider loadFileRepresentationForTypeIdentifier:typeIdentifier completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
            if (error) {
                NSString *errorMessage = [NSString stringWithFormat:[self translateString:@"Unable to load image: %@"], error.localizedDescription];
                [self showError:errorMessage];
            } else if (url) {
                NSData *data = [NSFileManager.defaultManager contentsAtPath:url.path];
                UIImage *image = [UIImage imageWithData:data];
                NSString *fileExtension = url.path.pathExtension;
                if (!fileExtension) {
                    fileExtension = @"jpg";
                }
                NSString *filename = [NSString stringWithFormat:@"photo.%@", fileExtension];
                [self upload:data filename:filename image:image];
            } else {
                [self dismissed];
            }
        }];
    } else {
        if (!typeIdentifier) {
            typeIdentifier = AVFileTypeMPEG4;
        }
        [itemProvider loadFileRepresentationForTypeIdentifier:typeIdentifier completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
            if (error) {
                NSString *errorMessage = [NSString stringWithFormat:[self translateString:@"Unable to load video: %@"], error.localizedDescription];
                [self showError:errorMessage];
            } else if (url) {
                NSData *data = [NSFileManager.defaultManager contentsAtPath:url.path];
                NSString *filename = [NSString stringWithFormat:@"%@.mov", NSUUID.UUID.UUIDString];
                [self upload:data filename:filename image:nil];
            } else {
                [self dismissed];
            }
        }];
    }
}

@end

