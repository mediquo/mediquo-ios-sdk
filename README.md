# MediQuoSDK

Welcome to MediQuoSDK for Apple Platforms,  the easiest way to integrate the MediQuo functionality into your app!

**Note:** If you are coming from one of the versions of the SDK previous to the v10.0 release, then this is a breaking change and you should delete all the integration you had before. 

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

In order to integrate the SDK, we support both UIKit-based apps (the ones with `AppDelegate` and `SceneDelegate`) and SwiftUI-bases apps (the ones with `@main` and `WindowGroup`)
