#import "HSAttachmentPickerPhotoPreviewController.h"

@implementation HSAttachmentPickerPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *image = [[UIImageView alloc] initWithImage:_info[UIImagePickerControllerOriginalImage]];
    self.view = image;
    self.view.backgroundColor = UIColor.whiteColor;
    self.view.contentMode = UIViewContentModeScaleAspectFit;
    self.title = [self translateString:@"Preview"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self translateString:@"Use"] style:UIBarButtonItemStyleDone target:self action:@selector(usePhoto)];
}

-(void)usePhoto {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
    [_delegate photoPreview:self usePhoto:self.info];
}

- (NSString *)translateString:(NSString *)key {
    NSBundle *bundle = self.translationsBundle ? self.translationsBundle : NSBundle.mainBundle;
    return [bundle localizedStringForKey:key value:nil table:self.translationTable];
}

@end
