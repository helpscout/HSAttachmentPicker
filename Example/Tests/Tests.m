#import "HSAttachmentPickerViewController.h"

SPEC_BEGIN(InitialTests)

describe(@"My initial tests", ^{

      it(@"should show picker menu", ^{
          HSAttachmentPickerViewController *controller = (HSAttachmentPickerViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
          [controller.openPickerButton sendActionsForControlEvents:UIControlEventTouchUpInside];
          [[controller.presentedViewController.class should] equal: UIAlertController.class];
      });
    
});

SPEC_END

