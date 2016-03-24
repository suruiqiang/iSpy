# iSpy
iSpy for iOS allows you to show UIView's size, cpu/memory/network information, and update any UIView's properties at runtime. Similar with Spy++, you could inspect any UIView of running application, change it's interface without build and run again. 

## ScreenShot

Show views hierarchy:  
![iSpy View Properties](https://raw.githubusercontent.com/tinymind/iSpy/master/ISpy_Example_ViewProperties.gif)

Show view's placeholder: 
![iSpy Place Holder](https://raw.githubusercontent.com/tinymind/iSpy/master/ISpy_Example_PlaceHolder.gif)

## Installation

### Add source code to project

Download [iSpy Folder](https://github.com/tinymind/iSpy/tree/master/iSpy), add to your XCode project.

### CocoaPods

Coming Soon...

## Dependency

[RATreeView](https://github.com/Augustyniak/RATreeView).

``` ruby
pod 'RATreeView', '~> 2.1.0'
```

## Usage

``` objc
#import "ISpy.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Setup
    [[ISpy sharedObject] show];
}

```

## Feature

* Show UIView's frame size, border.
* Show system data usage: cpu, memory, network.
* Show all UIViews' properties.
* Update any UIView's properties at runtime.

## Todo

* Hosts: support hosts for http request.
* Command: send message to any view.