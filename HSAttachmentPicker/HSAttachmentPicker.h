#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

@class HSAttachmentPicker;

@protocol HSAttachmentPickerDelegate<NSObject>

- (void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showController:(UIViewController *_Nonnull)controller completion:(void (^_Nullable)(void))completion;

- (void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showErrorMessage:(NSString *_Nonnull)errorMessage;

- (void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu upload:(NSData *_Nonnull)data filename:(NSString *_Nonnull)filename image:(UIImage *_Nullable)image;

@optional
- (void)attachmentPickerMenuDismissed:(HSAttachmentPicker *_Nonnull)menu;

@end

@interface HSAttachmentPicker : NSObject

@property (nonatomic, weak, nullable) id<HSAttachmentPickerDelegate> delegate;


/// The desired video quality to return selected movies in, defaults to UIImagePickerControllerQualityTypeMedium
@property (nonatomic) UIImagePickerControllerQualityType preferredVideoQuality;

/// An array that indicates the media types to be accessed by the media picker controller.  This maps to UIImagePickerController.mediaTypes so all applicable discussion applies to this property as well (e.g if empty the system will throw an exception)
/// Default: @[(NSString*)kUTTypeImage, (NSString*)kUTTypeMovie]
@property (nonatomic, copy, nonnull) NSArray<NSString *> *mediaTypes;

/// An array that passed to the `PHPickerConfiguration.filters` used to initialize the `PHPickerViewController`
///  Default: @[PHPickerFilter.imagesFilter, PHPickerFilter.livePhotosFilter, PHPickerFilter.videosFilter]
@property (nonatomic, copy, nullable) NSArray<PHPickerFilter *> *pickerFilters API_AVAILABLE(ios(14));

/// An array of uniform type identifiers (UTIs). UTIs are strings that uniquely identify a file’s type.
/// Default: @[(NSString*)kUTTypeItem]
@property (nonatomic, copy, nonnull) NSArray<NSString *> *documentTypes;

/// The bundle to use when accessing localizations.  If translationsBundle is nil or unset [NSBundle mainBundle] will be used.
@property (nonatomic, nullable) NSBundle *translationsBundle;

/// The name of the strings translation table to search. If translationTable is nil or is an empty string, translations will use the table in Localizable.strings.
@property (nonatomic, nullable) NSString *translationTable;

- (void)showAttachmentMenu;

@end
