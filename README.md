# RegexScanner

[![Version](https://img.shields.io/cocoapods/v/RegexScanner.svg?style=flat)](https://cocoapods.org/pods/RegexScanner)
[![License](https://img.shields.io/cocoapods/l/RegexScanner.svg?style=flat)](https://cocoapods.org/pods/RegexScanner)
[![Platform](https://img.shields.io/cocoapods/p/RegexScanner.svg?style=flat)](https://cocoapods.org/pods/RegexScanner)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 13 or newer
- Swift 5

## Installation

RegexScanner is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RegexScanner'
```

To Use:


```Swift
import RegexScanner 
```

And simple call 

```Swift
let scannerView = RegexScanner.getScanner(regex: "[A-Z]{2}[0-9]{9}[A-Z]{2}") { value in
    print(value)
}
present(scannerView, animated: true, completion: nil)
```

When the text is recognized, the view closes and the value is send to closure.

Do not forget add `NSCameraUsageDescription` to your Info.plist

You can custom the texts using the scannerView.:
- buttonConfirmTitle
- buttonConfirmBackgroundColor
- viewTitle

## Author

Narlei Moreira, narlei.guitar@gmail.com

If do you like, give your ⭐️

## License

RegexScanner is available under the MIT license. See the LICENSE file for more info.

## Pay me a coffee:

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=NMQM9R9GLZQXC&lc=BR&item_name=Narlei%20Moreira&item_number=development%2fdesign&currency_code=BRL&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)