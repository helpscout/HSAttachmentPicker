#import <XCTest/XCTest.h>
#import "HSAttachmentPickerViewController.h"

@interface HSAttachmentPickerTests : XCTestCase

@end

@implementation HSAttachmentPickerTests

- (void)testPresentingTheAttachmentPicker {
    HSAttachmentPickerViewController *controller = (HSAttachmentPickerViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [controller.openPickerButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    XCTAssertEqual(controller.presentedViewController.class, UIAlertController.class);
}

@end
