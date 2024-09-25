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
  let mediquo = try await MediQuo(apiKey: API_KEY, userID: USER_ID)
  let vc = mediquo.getSDKViewController(for: .professionalList)
  self.present(vc, animated: true)
}
```
After the `MediQuo` object is created, we call `getSDKViewController(for:)` in order to create a `UIViewController` and add it do the hierarchy as you see fit (in this example, we're presenting this View Controller modally). Equivalent APIs are available for SwiftUI-based apps.

All the possibles views are defined in `MediQuo.ViewKind` and you can use Xcode's autocomplete to find the appropiate view for any use case.

**Note:** You could create one instance of the `MediQuo` object tied to the lifetime of your App, just store it on your AppDelegate or any other way you manage your dependencies. Just make sure that if the user changes, call this method to deauthenticate the old one.

```swift
try? await mediquo.deauthenticateSDK()
```

## Push Integration

The MediQuo SDK supports Firebase-based pushes as well as regular APNS based ones.

<details>
<summary>Apple APNS</summary>

After you [explicitly request permission](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications#Explicitly-request-authorization-in-context) to send pushes to the user, make sure to override your App Delegate's `application(_:, didRegisterForRemoteNotificationsWithDeviceToken: Data)` and add:

```swift
try? await mediquo.setPushNotificationToken(type: .appleAPNS(data))
```
</details>

<details>
<summary>Firebase</summary>

First, you must obtain the [token from Firebase](https://firebase.google.com/docs/cloud-messaging/ios/client#fetching-the-current-registration-token) and once obtained (and every time it changes), you must pass it on to the Mediquo's SDK with the following code: 

```swift
try? await mediquo.setPushNotificationToken(type: .firebase(token))
```

</details>

When receiving a push, it is your app's responsability to parse the incoming message, create the MediQuo view and present it in order to allow the end user an opportunity to keep interacting with your app.

Example new message push payload

```swift
"data": {
      "module": "consultations",
      "room_id": "2152762",
      "message": "You have new unread messages",
      "type": "message_created"
  }
```

Example call push payload:

```swift
"data": {
    "module": "consultations",
    "professional_hash": "e38c51fe-e9e1-4cb0-8331-a6830910ca01",
    "professional_name": "Marc TLB Pro",
    "professional_avatar": "https://marqueting.s3.eu-central-1.amazonaws.com/avatars/user_placeholder.png",
    "call_session_id": "1_MX40NjY1NTEwMn5-MTcwMzY5MTI3NDgzOH4rKzR6dmkyUHJKNzk2a2pmZ0p1M0t4OW1-fn4",
    "call_token": "T1==cGFydG5lcl9pZD00NjY1NTEwMiZzaWc9OWVjZmNjMTJhYmMzNjdmYTgxZDVmMzM1MjJlMzZjYzRhNWFiOTM2ZjpzZXNzaW9uX2lkPTFfTVg0ME5qWTFOVEV3TW41LU1UY3dNelk1TVRJM05EZ3pPSDRyS3pSNmRta3lVSEpLTnprMmEycG1aMHAxTTB0NE9XMS1mbjQmY3JlYXRlX3RpbWU9MTcwMzY5MTI3NSZyb2xlPXB1Ymxpc2hlciZub25jZT0xNzAzNjkxMjc1LjAzNDMxMDg2NjM4NDA1JmNvbm5lY3Rpb25fZGF0YT04MzNjMzhkYS1hYTg0LTRhNGUtYTk3Ni1mZTRiNmE2ZTFiMDcmaW5pdGlhbF9sYXlvdXRfY2xhc3NfbGlzdD0=",
    "call_type": "video",
    "call_room_id": "2152762",
    "call_uuid": "e8ad9b4b-999f-4da1-a597-7d9b87a12a30",
    "title": "Incoming call",
    "image": "https://marqueting.s3.eu-central-1.amazonaws.com/avatars/user_placeholder.png",
    "type": "call_requested",
    }
```

## Permissions

The SDK allows the users to send voice notes, images and files, so in order to allow this functionality, you must add the following entries to your `Info.plist` with an appropiate description:

- `NSMicrophoneUsageDescription`
- `NSCameraUsageDescription`

### Customization

The SDK will use your app's [Accent Color](https://developer.apple.com/documentation/xcode/specifying-your-apps-color-scheme) to customize it's look and feel. If you need any more customization points, feel free to open an [Issue](https://github.com/mediquo/mediquo-ios-sdk/issues) in this Repository to request any feature.  

### Troubleshooting

During the SPM integration, in case you're find an issue such as "invalid archive returned from 'https://github.com/mediquo/mediquo-ios-sdk/releases/download/X.X.X/MediQuoSDK.xcframework.zip' which is required by binary target 'XXX'", close Xcode and run the following commands in your Terminal.

```
rm -rf $HOME/Library/Caches/org.swift.swiftpm/
rm -rf $HOME/Library/org.swift.swiftpm
```
