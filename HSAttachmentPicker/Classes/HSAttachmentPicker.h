#import <UIKit/UIKit.h>

@class HSAttachmentPicker;

@protocol HSAttachmentPickerDelegate

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showController:(UIViewController *_Nonnull)controller completion:(void (^_Nullable)(void))completion;

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu showErrorMessage:(NSString *_Nonnull)errorMessage;

-(void)attachmentPickerMenu:(HSAttachmentPicker *_Nonnull)menu upload:(NSData *_Nonnull)data filename:(NSString *_Nonnull)filename image:(UIImage *_Nullable)image;

@end

@interface HSAttachmentPicker : NSObject

@property (nonatomic, weak, nullable) id<HSAttachmentPickerDelegate> delegate;

-(void)showAttachmentMenu;

@end
