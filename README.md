# MediQuoSDK

Welcome to MediQuoSDK for Apple Platforms,  the easiest way to integrate the MediQuo functionality into your app!

This repository contains a sample app that you can inspect to see how to integrate the MediQuo SDK into your own Application.

## Prerequisites

- Xcode 26 or later
- iOS 17 Deployment Target

## Installation

We support installation via Swift Package Manager and as a standalone XCFramework.

### Swift Package Manager

- Go to your Xcode Project and add the package `https://github.com/mediquo/mediquo-ios-sdk.git` and add the Package to your app.

The `MediQuoSDK` product also includes Vonage Video Transformers 2.33.0,
which supplies the dynamic `OpenTokTransformers.framework` required at launch.
Swift Package Manager embeds this framework and copies its resource bundle
automatically. Keep this dependency aligned with the version used to build the SDK.

When installing `MediQuoSDK` through Swift Package Manager, you do not need to
add Vonage Transformers separately to your app or its `Package.swift`.

<img width="1000" alt="image" src="https://github.com/mediquo/mediquo-ios-sdk/assets/869981/25a5cec8-f98d-483b-87d8-f08db2bd6cea">

### XCFramework

Manual integrations must also add the Swift package
`https://github.com/Vonage/vonage-client-sdk-video-transformers.git`, select
version **2.33.0**, and link its `VonageClientSDKVideoTransformers` product to
the application target. This supplies the required framework and resources;
adding `MediQuoSDK.xcframework` alone causes a `Library not loaded:
@rpath/OpenTokTransformers.framework/OpenTokTransformers` error at launch.

- From the [Releases](https://github.com/mediquo/mediquo-ios-sdk/releases) tab of the Repo, choose the latest release, expand Assets and download the ZIP file

<img width="960" alt="image" src="https://github.com/user-attachments/assets/3cec5997-15e2-4a6a-9c01-12ec5c2322c1">

- Drag and Drop it in Xcode, link the framework to your target and make sure that the XCFramework is "Embedded and Signed" into your App target.

<img width="632" alt="image" src="https://github.com/mediquo/mediquo-ios-sdk/assets/869981/3a6c40d3-f5db-426e-94dc-db23a79d6afe">

## Integration

See the [SwiftUI demo](MediQuoSDKDemo/MediQuoSDKDemo/MediQuoSDKDemoApp.swift)
and [UIKit demo](MediQuoSDKDemo/MediQuoSDKUIKitDemo/ViewController.swift) in
[MediQuoSDKDemo](MediQuoSDKDemo) for integration examples.

In order to integrate the SDK, we support both UIKit-based apps (the ones with `AppDelegate` and `SceneDelegate`) and SwiftUI-based apps (the ones with `@main` and `WindowGroup`).

We recommend initializing the SDK right after an entitled user logs in. Before doing this, make sure you have at hand these two values:
- `API_KEY`: provided by mediQuo
- `USER_ID`: created with [Patients API](https://developer.mediquo.com/docs/api/patients/)

You initialize it simply:

```swift
Task {
  self.mediquo = try await MediQuo(apiKey: API_KEY, userID: USER_ID)
}
```
After the `MediQuo` object is created, we call `sdkViewController(for:)` in order to create a `UIViewController` and add it do the hierarchy as you see fit (in this example, we're presenting this View Controller modally). Equivalent APIs are available for SwiftUI-based apps.

```swift
let vc = self.mediquo.sdkViewController(for: .professionalList)
self.present(vc, animated: true)
```

### Available views

All SDK screens are defined in `MediQuo.ViewKind`. Pass any of the following
values to `sdkView(for:)` for SwiftUI or `sdkViewController(for:)` for UIKit.
The views use the authenticated patient's data and the services enabled for
their account.

| `MediQuo.ViewKind` | Screen | Parameters |
| --- | --- | --- |
| `.professionalList()` | List of healthcare professionals and conversations. | Optional `supportButton: MediQuo.ViewKind.SupportButtonConfiguration`, defaults to `nil`. |
| `.schedule` | Agenda with upcoming and past appointments. | None. |
| `.newAppointment` | Consultation booking flow, starting with specialist search. | None. |
| `.immediateConsultations` | Available immediate consultations, continuing to payment or the waiting room. | None. |
| `.appointmentsDetails(appointmentID:)` | Details of an existing appointment. | Required `appointmentID: String`. |
| `.chat(roomID:)` | An existing chat with a professional. | Required `roomID: Int`, also supplied in chat push notification payloads. |
| `.medicalHistory` | Medical history overview. | None. |
| `.allergies` | Allergies. | None. |
| `.diseases` | Diseases. | None. |
| `.medicalReport` | Medical reports. | None. |
| `.medication` | Medication list. | None. |
| `.prescription` | Prescriptions. | None. |
| `.documentation` | Downloadable documents. | None. |
| `.call(callViewModel:closeHandler:)` | Incoming video call screen. | Required `callViewModel: MediQuo.CallViewModel`; optional `closeHandler`, defaults to `nil`. |

To add a support button to `.professionalList(supportButton:)`, provide a
`MediQuo.ViewKind.SupportButtonConfiguration` with a `title` and an `onTap`
callback. Its `image` is optional and its `backgroundColor` defaults to
`.accentColor`.

For `.call`, use the `MediQuo.CallViewModel` supplied by
[`MediQuoEventDelegate.didReceiveCall(_:)`](#listening-to-events), or construct
one from the incoming call payload. Use the optional `closeHandler` to clear
your app's call presentation state. This entry point presents an existing
incoming call; to start a consultation flow, use `.newAppointment` or
`.immediateConsultations`.

**Note:**
For most applications, we recommend instantiating a single `MediQuo` object at the start of an entitled user’s session. Store this instance in AppDelegate or within your dependency management system to ensure consistent access throughout the app.

However, if the user logs out, make sure to call this method to deauthenticate and clean up the instance properly:

```swift
try? await mediquo.deauthenticateSDK()
```

This prevents unauthorized access and ensures a fresh state when a new user logs in.

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

First, you should request the user’s permission in the same way as you would when using Apple’s APNS integration. Then, obtain the[token from Firebase](https://firebase.google.com/docs/cloud-messaging/ios/client#fetching-the-current-registration-token). Once obtained (and whenever it changes), pass it to Mediquo’s SDK using the following code: 

```swift
try? await mediquo.setPushNotificationToken(type: .firebase(token))
```

</details>

### Incoming Push Parsing

In order to allow the user an opportunity to keep interacting with your app when receiving a push, we offer an affordance API to parse the incoming push payload into a MediQuo view. However, it is your responsibility as the app's owner to call this API and present this view as you see fit.

For example:

```swift
public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
  let userInfo = notification.request.content.userInfo as? [String: any Sendable]
  /// Handle pushes from other sources different from Mediquo
  /// and only call the MediQuo SDK if you haven't handled this push yourself
  
  /// Generate a ViewController from the remote push payload
  let vc = self.mediquo.getSDKViewController(forRemotePush: userInfo)
  
  // Present the ViewController returned by the MediQuoSDK however you want.
  self.rootViewController.present(vc, animated: true)
  completionHandler()
}
```

You can find an example of notification payloads [here](https://github.com/mediquo/mediquo-ios-sdk/blob/main/SamplePushNotifications).

- To test with the simulator, [Drag and drop](https://www.avanderlee.com/workflow/testing-push-notifications-ios-simulator/) the APNS file, and remember to replace $BUNDLE_ID with your app's Bundle ID.

## Listening to Events

In order to listen to events, make sure you conform with the `MediQuoEventDelegate` protocol and set an instance of that object as the delegate using:

```swift
self.mediquo.eventDelegate = self
```

You can listen to events like socket connection changes or incoming calls. Please refer to the [Sample App](https://github.com/mediquo/mediquo-ios-sdk/blob/main/MediQuoSDKDemo/MediQuoSDKUIKitDemo/ViewController.swift#L10) code in order to see how to integrate this functionality.

**Note:** As of version 10.7.1 of the SDK, if an incoming call is received and `eventDelegate` is nil, `MediQuo` will attempt to present a full screen `UIViewController` to handle that call.

## Permissions

The SDK allows the users to send voice notes, images and files, so in order to allow this functionality, you must add the following entries to your `Info.plist` with an appropiate description:

- `NSMicrophoneUsageDescription`
- `NSCameraUsageDescription`

### Customization

The SDK will use your app's [Accent Color](https://developer.apple.com/documentation/xcode/specifying-your-apps-color-scheme) to customize it's look and feel. If you need any more customization points, feel free to open an [Issue](https://github.com/mediquo/mediquo-ios-sdk/issues) in this Repository to request any feature.  

### Troubleshooting

During the SPM integration, in case you find an issue such as "invalid archive returned from 'https://github.com/mediquo/mediquo-ios-sdk/releases/download/X.X.X/MediQuoSDK.xcframework.zip' which is required by binary target 'XXX'", close Xcode and run the following commands in your Terminal.

```
rm -rf $HOME/Library/Caches/org.swift.swiftpm/
rm -rf $HOME/Library/org.swift.swiftpm
```
