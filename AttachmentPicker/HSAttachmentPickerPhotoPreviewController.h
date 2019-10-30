#import <UIKit/UIKit.h>

@class HSAttachmentPickerPhotoPreviewController;

@protocol HSAttachmentPickerPhotoPreviewControllerDelegate

-(void)photoPreview:(HSAttachmentPickerPhotoPreviewController *_Nonnull)photoPreview usePhoto:( NSDictionary<NSString *,id> *_Nonnull)info;

@end

@interface HSAttachmentPickerPhotoPreviewController : UIViewController

@property (nonatomic, weak, nullable) id<HSAttachmentPickerPhotoPreviewControllerDelegate> delegate;

@property (nonatomic, strong, nonnull) NSDictionary<NSString *,id> *info;

/**
 * This will default to NSBundle.mainBundle unless specified
 */
@property (nonatomic, nullable) NSBundle *translationsBundle;

/**
 * Use this specific .strings file for translations, uses system default (Localizable.strings) otherwise
 */
@property (nonatomic, nullable) NSString *translationTable;

@end
