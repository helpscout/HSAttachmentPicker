# HSAttachmentPicker

[![CI Status](http://img.shields.io/travis/helpscout/HSAttachmentPicker.svg?style=flat)](https://travis-ci.org/helpscout/HSAttachmentPicker)
[![Version](https://img.shields.io/cocoapods/v/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)
[![License](https://img.shields.io/cocoapods/l/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)
[![Platform](https://img.shields.io/cocoapods/p/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)

`HSAttachmentPicker` creates a `UIAlertController` as a menu to access file data from photos, the camera, and the document browser APIs available on iOS.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_preview.png" width="376" height="648">

## Usage

You'll want to create a new `HSAttachmentPicker`, assign a delegate, and call `showAttachmentMenu`.

```objective-c
HSAttachmentPicker *menu = [[HSAttachmentPicker alloc] init];
menu.delegate = self;
[menu showAttachmentMenu];
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example project only contains a simple delegate that logs the operations for demonstration purposes.

## Requirements

In order to use the photo and camera related features, the `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` properties need to be set in your application's `Info.plist` file. Without these the menu items will be unavailable.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_photo_permissions.png" width="650" height="376">

For access to the document picker, you'll need the entitlements for iCloud and iCloud Containers. This will throw an error message via the delegate on the 'Import file from' menu option otherwise.

<img src="https://github.com/helpscout/HSAttachmentPicker/raw/master/picker_icloud_permissions.png width="856" height="346">

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
```

By default it will check `NSBundle.mainBundle` and `Localizable.strings`, but these values can be overriden with the `translationsBundle` and `translationsTable` properties on the `HSAttachmentPicker` object.

## License

HSAttachmentPicker is available under the MIT license. See the LICENSE file for more info.
