#import "HSAttachmentPickerViewController.h"

#import <HSAttachmentPicker/HSAttachmentPicker.h>

@interface HSAttachmentPickerViewController () <HSAttachmentPickerDelegate>

@end

@implementation HSAttachmentPickerViewController

- (IBAction)openMenu:(id)sender {
    HSAttachmentPicker *menu = [[HSAttachmentPicker alloc] init];
    menu.delegate = self;
    menu.translationTable = @"HSAttachmentPicker";
    [menu showAttachmentMenu];
}

- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showController:(UIViewController * _Nonnull)controller completion:(void (^ _Nullable)(void))completion {
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    if (popover != nil) {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popover.sourceView = self.openPickerButton;
    }
    [self presentViewController:controller animated:true completion:completion];
}

- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu showErrorMessage:(NSString * _Nonnull)errorMessage {
    NSLog(@"%@", errorMessage);
}

- (void)attachmentPickerMenu:(HSAttachmentPicker * _Nonnull)menu upload:(NSData * _Nonnull)data filename:(NSString * _Nonnull)filename image:(UIImage * _Nullable)image {
    NSLog(@"uploading %@", filename);
}

- (void)attachmentPickerMenuDismissed:(HSAttachmentPicker *)menu {
    NSLog(@"dismissed");
}

@end
