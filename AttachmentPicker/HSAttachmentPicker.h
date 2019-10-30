#import <UIKit/UIKit.h>

@class HSAttachmentPicker;

@protocol HSAttachmentPickerDelegate<NSObject>

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showController:(UIViewController *_Nonnull)controller completion:(void (^_Nullable)(void))completion;

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showErrorMessage:(NSString *_Nonnull)errorMessage;

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu upload:(NSData *_Nonnull)data filename:(NSString *_Nonnull)filename image:(UIImage *_Nullable)image;

@optional
-(void)attachmentPickerMenuDismissed:(HSAttachmentPicker *_Nonnull)menu;

@end

@interface HSAttachmentPicker : NSObject

@property (nonatomic, weak, nullable) id<HSAttachmentPickerDelegate> delegate;


/// The desired video quality to return selected movies in
/// Defaults to UIImagePickerControllerQualityTypeMedium
@property (nonatomic) UIImagePickerControllerQualityType preferredVideoQuality;

/**
 * This will default to NSBundle.mainBundle unless specified
 */
@property (nonatomic, nullable) NSBundle *translationsBundle;

/**
 * Use this specific .strings file for translations, uses system default (Localizable.strings) otherwise
 */
@property (nonatomic, nullable) NSString *translationTable;

-(void)showAttachmentMenu;

@end
