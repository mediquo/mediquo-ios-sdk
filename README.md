# MediQuoSDK

Welcome to MediQuoSDK for Apple Platforms,  the easiest way to integrate the MediQuo functionality into your app!

This repository contains a sample app that you can inspect to see how to integrate the MediQuo SDK into your own Application.

**Note:** If you are coming from one of the versions of the SDK previous to the v10.0 release, then this is a breaking change and you should delete all the integration you had before continuing. 

## Prerequisites

- Xcode 15 or later
- iOS 15 Deployment Target

## Installation

We support installation via Swift Package Manager and as a standalone XCFramework.

### Swift Package Manager

- Go to your Xcode Project and add the package `https://github.com/mediquo/mediquo-ios-sdk.git` and add the Package to your app.

<img width="1000" alt="image" src="https://github.com/mediquo/mediquo-ios-sdk/assets/869981/25a5cec8-f98d-483b-87d8-f08db2bd6cea">

### XCFramework

- From the [Releases](https://github.com/mediquo/mediquo-ios-sdk/releases) tab of the Repo, choose the latest release, expand Assets and download the ZIP file

<img width="449" alt="image" src="https://github.com/mediquo/mediquo-ios-sdk/assets/869981/2e10584e-fbfe-4e9a-9489-59a04e3000d4">

- Drag and Drop it in Xcode, link the framework to your target and make sure that the XCFramework is "Embedded and Signed" into your App target.

<img width="632" alt="image" src="https://github.com/mediquo/mediquo-ios-sdk/assets/869981/3a6c40d3-f5db-426e-94dc-db23a79d6afe">

## Integration

In order to integrate the SDK, we support both UIKit-based apps (the ones with `AppDelegate` and `SceneDelegate`) and SwiftUI-based apps (the ones with `@main` and `WindowGroup`).

Before you present the SDK make sure you have at hand these two values:
- `API_KEY`: provided by mediQuo
- `USER_ID`: created with [Patients API](https://developer.mediquo.com/docs/api/patients/)

Whenever you want to present the MediQuo functionality, use the following pattern:

```swift
Task {
  let mediquo = try await MediQuo(environment: .production, apiKey: API_KEY, userID: USER_ID)
  let vc = mediquo.getSDKViewController(for: .professionalList)
  self.present(vc, animated: true)
}
```
After the `MediQuo` object is created, we call `getSDKViewController(for:)` in order to create a `UIViewController` and add it do the hierarchy as you see fit (in this example, we're presenting this View Controller modally). Equivalent APIs are available for SwiftUI-based apps.

All the possibles views are defined in `MediQuo.ViewKind` and you can use Xcode's autocomplete to find the appropiate view for any use case.

**Note:** You could create one instance of the `MediQuo` object tied to the lifetime of your App, just store it on your AppDelegate or any other way you manage your dependencies. Just make sure that if the user changes, this object gets recreated so the `USER_ID` is updated.

## Push Integration

The MediQuo SDK supports Firebase-based pushes as well as regular APNS based ones.

Make sure to override your App Delegate's `application(_:, didRegisterForRemoteNotificationsWithDeviceToken: Data)` and add:

```swift
try? await mediquo.pushNotification(data, type: .appleAPNS)
```

When receiving a push, it is your app's responsability to parse the incoming message, create the MediQuo view and present it in order to allow the end user an opportunity to keep interacting with your app.

### Customization

The SDK will use your app's [Accent Color](https://developer.apple.com/documentation/xcode/specifying-your-apps-color-scheme) to customize it's look and feel. If you need any more customization points, feel free to open an [Issue](https://github.com/mediquo/mediquo-ios-sdk/issues) in this Repository to request any feature.  
