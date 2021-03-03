# Simple Rate My App

![In-App Review Android Demo](https://github.com/britannio/in_app_review/blob/master/in_app_review/screenshots/android.jpg)
![In-App Review IOS Demo](https://github.com/britannio/in_app_review/blob/master/in_app_review/screenshots/ios.png)

## Getting Started
```dart
SimpleRateMyApp.init(
    // Define your rule (or just use the default rule)
    canShow: () {
        return SimpleRateMyApp.daysElapsed == 8;
    }
    // Define your callback when the rule is true
    onShow: (){
        // Your Custom Rate Dialog
    },
);
```
