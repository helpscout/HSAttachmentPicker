# HSAttachmentPicker

[![CI Status](http://img.shields.io/travis/helpscout/HSAttachmentPicker.svg?style=flat)](https://travis-ci.org/helpscout/HSAttachmentPicker)
[![Version](https://img.shields.io/cocoapods/v/AttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/AttachmentPicker)
[![License](https://img.shields.io/cocoapods/l/AttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/AttachmentPicker)
[![Platform](https://img.shields.io/cocoapods/p/AttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/AttachmentPicker)

`HSAttachmentPicker` creates a `UIAlertController` as a menu to access file data from photos, the camera, and the document browser APIs available on iOS.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_preview.png" width="376" height="648">

## Usage

To use the attachment picker, create a new `HSAttachmentPicker` instance, assign a delegate, and call `showAttachmentMenu`.

#### Objective-C

You can find a full example of using the attachment picker in the [example project](Example).

```objective-c
HSAttachmentPicker *menu = [[HSAttachmentPicker alloc] init];
menu.delegate = self;
[menu showAttachmentMenu];
```

#### Swift

```swift
class ViewController: UIViewController {
  let picker = HSAttachmentPicker()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    picker.delegate = self
    picker.showAttachmentMenu()
  }
}

extension ViewController: HSAttachmentPickerDelegate {
  func attachmentPickerMenu(_ menu: HSAttachmentPicker, showErrorMessage errorMessage: String) {
    // Handle errors
  }

  func attachmentPickerMenuDismissed(_ menu: HSAttachmentPicker) {
    // Run some code when the picker is dismissed
  }

  func attachmentPickerMenu(_ menu: HSAttachmentPicker, show controller: UIViewController, completion: (() -> Void)? = nil) {
    self.present(controller, animated: true, completion: completion)
  }

  func attachmentPickerMenu(_ menu: HSAttachmentPicker, upload data: Data, filename: String, image: UIImage?) {
    // Do something with the data of the selected attachment, i.e. upload it to a web service
  }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example project only contains a simple delegate that logs the operations for demonstration purposes.

## Requirements

In order to use the photo and camera related features, the `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` and `NSPhotoLibraryAddUsageDescription` properties need to be set in your application's `Info.plist` file. Without these the menu items will be unavailable.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_photos_permissions.png" width="787" height="99">

For access to the document picker, you'll need the entitlements for iCloud and iCloud Containers. This will throw an error message via the delegate on the 'Import file from' menu option otherwise.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_icloud_permissions.png" width="856" height="346">

## Installation

HSAttachmentPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HSAttachmentPicker'
```

## Localization

The following strings can be specified to override the default messaging:

```
/* Menu Items */

"Take Photo"="Take Photo";

"Use Last Photo"="Use Last Photo";

"Choose from Library"="Choose from Library";

"Import File from"="Import File from";

"Cancel"="Cancel";

"OK"="OK";

/* Errors */

"This application is not entitled to access iCloud"="This application is not entitled to access iCloud";

"There doesn't seem to be a photo taken yet."="There doesn't seem to be a photo taken yet.";

"To give permissions tap on 'Change Settings' button"="To give permissions tap on 'Change Settings' button";

"Unable to save video: %@"="Unable to save video: %@";

"Unable to save photo: %@"="Unable to save photo: %@";

"Selected media type is unsupported"="Selected media type is unsupported";

/* Preview */

"Preview": "Preview";

"Use": "Use";
```

By default it will check `NSBundle.mainBundle` and `Localizable.strings`, but these values can be overriden with the `translationsBundle` and `translationTable` properties on the `HSAttachmentPicker` object.

## License

HSAttachmentPicker is available under the MIT license. See the LICENSE file for more info.
