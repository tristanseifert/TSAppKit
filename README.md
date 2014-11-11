# TSAppKit
**TSAppKit** serves as a supplement to Apple's AppKit framework, providing several commonly-used functionalities, controls, and behaviours. This encourages code re-use, and saves time by having code only be implemented in one single place.

## Preferences Window
Provides a Mac OS X standard preferences window, implementing all the subtle behaviours users expect.

![alt tag](https://raw.github.com/tristanseifert/TSAppKit/master/Screenshots/prefs1.png)

Information about each individual panel is read from a plist within the main bundle's Resources folder. This file should be named `TSPreferencesPanels.plist` and contain an array of dictionaries under the key `panels`. 

Each of these dictionaries describes a preference panel—the first entry in the array describing the leftmost icon in the window.

Keys parsed by the preferences controller are:

* **title**: String displayed in the bar at the top of the window, and the window title when the panel is selected. (Required)
* **icon**: Name of an image to display above the text string in the window's tab bar. This is passed straight to `NSImage imageNamed:` so a system image, such as `NSImageNamePreferencesAdvanced` can be used. If omitted, `NSImageNamePreferencesGeneral` is used.
* **class**: Class name of an NSViewController instance that controls the logic and UI for a specific preference pane. This controller should implement `init` to either load the required NIB, or build the UI programmatically.
* **identifier**: A unique identifier that is saved by the preferences controller to restore the panel that was selected last.
* **description**: An optional description for the preference pane.

Additionally, the root dictionary has some configuration variables as well:

* **saveState**: When set to YES, the selected panel is stored in `NSUserDefaults` and restored next time the controller is instantiated.

Panels' views may be of differing sizes, both in the X and Y directions: the controller automatically adjusts the window's size to account for this. However, it is standard practice to maintain a constant width, and change only the height.

## License
See `LICENSE.md` for licensing information. If you use this library, just add a little line somewhere that you found this helpful. A link would be nice, but it's not required—just don't go claiming it as your own work!
