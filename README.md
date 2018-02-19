# SandboxExplorer

[![Version](https://img.shields.io/cocoapods/v/SandboxExplorer.svg?style=flat)](http://cocoapods.org/pods/SandboxExplorer)
[![License](https://img.shields.io/cocoapods/l/SandboxExplorer.svg?style=flat)](http://cocoapods.org/pods/SandboxExplorer)
[![Platform](https://img.shields.io/cocoapods/p/SandboxExplorer.svg?style=flat)](http://cocoapods.org/pods/SandboxExplorer)

Simple debugging tool for exploring the contents of your iOS app sandbox and identifying size changes in stored files.

![Screenshot 1](ss1.png?raw=true "Screenshot1")
![Screenshot 2](ss2.png?raw=true "Screenshot2")

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

SandboxExplorer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SandboxExplorer"
```

Show the SandboxExplorer UI using:
```ruby
import SandboxExplorer

SandboxExplorer.shared.toggleVisibility()
```

Tip! Add "shake to show" functionality to your root viewcontroller.
```ruby
import SandboxExplorer

class MyRootViewController: UIViewController {

  override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            SandboxExplorer.shared.toggleVisibility()
        }
    }
}
```

## Changelog

2.0.0 - Swift 4 upgrade
1.0.0 - Initial release (Swift 3.2)


## Author

Erik Sundin, erik@eriksundin.se

## License

SandboxExplorer is available under the MIT license. See the LICENSE file for more info.
