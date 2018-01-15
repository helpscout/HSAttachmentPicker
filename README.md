# HSAttachmentPicker

[![CI Status](http://img.shields.io/travis/helpscout/HSAttachmentPicker.svg?style=flat)](https://travis-ci.org/helpscout/HSAttachmentPicker)
[![Version](https://img.shields.io/cocoapods/v/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)
[![License](https://img.shields.io/cocoapods/l/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)
[![Platform](https://img.shields.io/cocoapods/p/HSAttachmentPicker.svg?style=flat)](http://cocoapods.org/pods/HSAttachmentPicker)

`HSAttachmentPicker` creates a `UIAlertController` as a menu to access file data from photos, the camera, and the document browser APIs available on iOS.

<img src="https://dha4w82d62smt.cloudfront.net/items/3g1Q1K3Y1K3R0B2T2M3T/Screen%20Shot%202017-12-29%20at%2011.30.48%20AM.png?X-CloudApp-Visitor-Id=db37a86382f770e73a24232f220b0404&v=ffa99392" width="376" height="648">

## Usage

You'll want to create a new `HSAttachmentPicker`, assign a delegate, and call `showAttachmentMenu`.

```objective-c
menu = [[HSAttachmentPicker alloc] init];
menu.delegate = self;
[menu showAttachmentMenu];
```

It's important you class holds a reference to the `HSAttachmentPicker` so it doesn't get garbage collected.




## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example project only contains a simple delegate that logs the operations for demonstration purposes.

## Requirements

In order to use the photo and camera related features, the `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` properties need to be set in your application's `Info.plist` file. Without these the menu items will be unavailable.

<img src="https://dha4w82d62smt.cloudfront.net/items/0q463a0w0b0l2U0I3o2f/Screen%20Shot%202017-12-29%20at%2011.02.44%20AM.png?X-CloudApp-Visitor-Id=7899bce0e49c330d2c95ab9d9ffadbcc&v=b2bdeb49" width="650" height="376">

For access to the document picker, you'll need the entitlements for iCloud and iCloud Containers. This will throw an error message via the delegate on the 'Import file from' menu option otherwise.

<img src="https://dha4w82d62smt.cloudfront.net/items/2o0R1Q1a3S002X0u022G/Screen%20Shot%202017-12-29%20at%2011.18.58%20AM.png?X-CloudApp-Visitor-Id=63cbad177969072645e6d311181cc23f&v=e155ea2f" width="856" height="346">

## Installation

HSAttachmentPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HSAttachmentPicker'
```

## License

HSAttachmentPicker is available under the MIT license. See the LICENSE file for more info.
