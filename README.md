# LikeMinds-GroupChat-MM

This is a Flutter sample UI package. It is a UI wrapper around the LikeMinds Chat SDK for Flutter, found [here](https://pub.dev/packages/likeminds_chat_fl/). It provides an even simpler way to add LikeMinds Chat to your Flutter app. Or just run a sample app to feel the experience.

## Features

Get access to the LikeMinds Chat Sample UI built for our platform. It provides the following features:

- Home Feed
- ChatRooms
- Media Attachment
- Push Notifications
- Realtime Chat

## Getting started

Follow the [documentation](https://docs.likeminds.community) to create a LikeMinds account and get access to your API key. This is a prerequisite.

After cloning the repository, the sample app lives in the example folder. Run the main function to start the sample app.

```dart
main();
```

The sample app already has a test community loaded, and serves as a good starting point to understand the package. Do not modify the sample app directly. Instead, create a new Flutter project and add the package as a dependency.

The sample UI package has componenets which you can use in your own code by using this package locally by providing a path to the root directory of this cloned repository in your `pubspec.yaml` file.

## Installation

Clone or fork this repository. Then add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  likeminds_chat_mm_fl:
    path: <path to cloned repository>
```

## Usage

In your code, import the package:

```dart
import 'package:likeminds_chat_mm_fl/likeminds_chat_mm_fl.dart';
```

Please note - Before using the package, there are some prerequisites. Which you can found listed below in the [Prerequisites](#prerequisites) section.

Then, to get the instance of the LikeMinds Chat UI, use the following:

```dart
final LMChat lmChat = LMChat.instance(
    builder: LMChatBuilder()
    ..userId(String userId)
    ..userName(String username)
    ..defaultChatroom(int? defaultChatroom)
);
```

The LMChat instance is of the type `MaterialApp`. So you can use it as you would use a `MaterialApp` widget. To see how it can be used, check out the sample app in the example folder.

### Prerequisites

First and foremost, before using `LMChat.instance()` you need to setup the LikeMinds Chat SDK. To do this, take inspiration from the `example/main.dart` file.

```dart
LMChat.setupLMChat(
    apiKey: String apiKey,
    lmCallBack: LMSdkCallback lmCallBack,
);
```

Then you have to initialize the `LMNotificationHandler` builtin to the package, to allow for push notifications to be received. To do this, use the following:

```dart
LMNotificationHandler.instance.init(
    deviceId: String devId,
    fcmToken: String fcmToken,
);
```

Finally, initializre the `LMBranding` class to provide your own branding themes to the package. You have to call this function once, even if you are using the default branding values. To do this, use the following:

```dart
LMBranding.instance.initialize(
    headerColor: Color? header,
    buttonColor: Color? button,
    textLinkColor: Color? textLink,
    fonts: LMFonts.instance.initialize(
        regular: TextStyle? regular,
        medium: TextStyle? medium,
        bold: TextStyle? bold,
    ),
);
```

Other prerequisites generally include setting your own project in the right way, taking care of all the permissions your app needs, building for latest platform versions and so on. For more information, read the code in `example/lib` or check out the [documentation](https://docs.likeminds.community).

## Additional information

To start using notifications properly, you need to configure at what times your FCM library will receive the message and call the `LMNotificationHandler.instance.handleNotification())` function. Check out `example/lib` for more.
