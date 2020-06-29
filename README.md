# Simple RateMyApp

## Getting Started
```dart
SimpleRateMyApp.init(
    // Define your rule (or just use the default rule)
    ruleToShow: () {
        return SimpleRateMyApp.daysElapsed == 8;
    }
    // Define your callback when the rule is true
    onShowAndroid: (){
        // Your Custom Rate Dialog
    },
    onShowIOS: () {
        // Your Custom Rate Dialog
        // or 
        // default: SimpleRateMyApp.openIosRateDialog();
    },
);
```

### All Functions

```dart
SimpleRateMyApp.init();
SimpleRateMyApp.show(); // check rule and active callback
SimpleRateMyApp.reset(); 
SimpleRateMyApp.dontShowMore();
SimpleRateMyApp.daysElapsed // int
SimpleRateMyApp.launchesElapsed // int
SimpleRateMyApp.openStore();  // Navigates to Store Listing in Google Play/App Store.
SimpleRateMyApp.openIosRateDialog(); // Open Native Ios Rate Dialog
```