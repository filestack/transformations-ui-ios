# Transformations UI

Filestack's [Transformations UI](https://www.filestack.com/docs/transformations/ui/) implementation for iOS and iPadOS.

**Transformations UI** is shipped as a Swift Package.

**NOTE**: *Starting in version `1.2.0`, all modules (previously categorized as either Standard or Premium) are now part of this Swift Package.*

## Requirements

* Xcode 12+
* Swift 4.2+ / Objective-C
* iOS 11.0+ / iPadOS 13.0+

## Installation

To install our Swift Package, please follow the steps below:

- Add `https://github.com/filestack/transformations-ui-ios.git` as a [Swift Package Manager](https://swift.org/package-manager/) dependency to your project.
- When asked to **Choose Package Options**, use the default settings provided by Xcode.
- When asked to **Add Package**, add `TransformationsUI` to your desired target(s).

## Usage

1. Import `TransformationsUI`

    ```swift
    import TransformationsUI
    ```

2. Instantiate `TransformationsUI` and set delegate

    ```swift
    let transformationsUI = TransformationsUI()
    transformationsUI.delegate = self
    ```

3. Add conformance to `TransformationsUIDelegate`

    ```swift
    extension ViewController: TransformationsUIDelegate {
        func editorDismissed(with image: UIImage?) {
            if let image = image {
                // TODO: Do something with resulting image...
            }
        }
    }
    ```

4. Present `TransformationsUI` view controller

    ```swift
    if let editorVC = transformationsUI.editor(with: image) {
        editorVC.modalPresentationStyle = .fullScreen
        present(editorVC, animated: true)
    }
    ```

## Modules Features

Below you will find an exhaustive list of configurable properties and commands per module.

### Transform Module

#### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Resize | Image resize | None | `extraCommands` |
| Flip | Flip image along the horizontal axis | None | `extraCommands` |
| Flop | Flip image along the vertical axis | None | `extraCommands` |
| Rotate | Rotate image 90 degrees | `clockwise: true/false` | `extraCommands` |
| Crop | |  | `cropCommands` |
|      | Crop image freely (no constraints) | `type: .rect, aspectRatio: .free` | `cropCommands` |
|      | Crop image using original image aspect ratio | `type: .rect, aspectRatio: .original` | `cropCommands` |
|      | Crop image using a custom aspect ratio | `type: .rect, aspectRatio: .custom(CGSize)` | `cropCommands` |
|      | Circle crop image | `type: .circle` | `cropCommands` |

### Filters Module

#### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| None | Does not apply any filter | None | `commands` |
| Chrome | Applies a chrome effect to image | None | `commands` |
| Fade | Applies a fade effect to image | None | `commands` |
| Instant | Applies an instant effect to image | None | `commands` |
| Mono | Applies a mono effect to image | None | `commands` |
| Noir | Applies a noir effect to image | None | `commands` |
| Process | Applies a process effect to image | None | `commands` |
| Tonal | Applies a tonal effect to image | None | `commands` |
| Transfer | Applies a transfer effect to image | None | `commands` |

### Adjustments Module

#### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Blur | Applies gaussian blur to image *(interactive)* | None | `commands` |
| Brightness | Allows adjusting image brightness *(interactive)* | None | `commands` |
| Contrast | Allows adjusting image contrats *(interactive)* | None | `commands` |
| Gamma | Allows adjusting RGB gamma components separately *(interactive)*  | None | `commands` |
| Hue | Allows adjusting image hue 360 degrees *(interactive)* | None | `commands` |

### Text Module

#### Properties

| Property | Purpose | Example |
|---|---|---|
| `availableFontFamilies` | Defines the list of font families available in the editor | `["Courier", "Futura", "Helvetica", "Times New Roman"]`|
| `defaultFontFamily` | Defines the default font family | `"Helvetica"`|
| `defaultFontColor` | Defines the default font color | `.white`|
| `defaultFontStyle` | Defines the default font style | `[.bold, .underline]`|
| `defaultTextAlignment` | Defines the default text alignment | `.left`|

#### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| SelectFontFamily | Allows user to select a font family amongst families listed in `availableFontFamilies` | None | `commandsInGroups` |
| SelectFontColor | Allows user to select a font color | None | `commandsInGroups` |
| SelectFontStyle | Allows user to toggle font style options (`.bold`, `.italic`, `.underline`) | None | `commandsInGroups` |
| SelectTextAlignment | Allows user to select text alignment (`.left`, `.center`, `.right`, `.justified`)  | None | `commandsInGroups` |

### Stickers Module *(added in 1.1)*

#### Properties

| Property | Purpose | Example |
|---|---|---|
| `stickers` | Defines the available stickers grouped by stickerset | `["Stickerset 1": [UIImage, UIImage], "Stickerset 2": [UIImage, UIImage]]`|

### Overlays Module *(added in 1.1.3)*

#### Properties

| Property | Purpose | Example |
|---|---|---|
| `filestackAPIKey` | Filestack's API key required to pick images using Filestack's picker.| `"YOUR-API-KEY-HERE"` |
| `filestackAppSecret` | Filestack's APP secret required to pick images using Filestack's picker.| `"YOUR-APP-SECRET"` |
| `callbackURLScheme` | Required by Filestack's picker to complete the cloud provider's authentication flow (only required if any cloud sources are available.)| `"transformationsuidemo"` |
| `availableCloudSources` | The list of [cloud sources](https://filestack.github.io/filestack-ios/Classes/CloudSource.html) available to Filestack's picker.| `[.dropbox, .googleDrive, .googlePhotos]` |
| `availableLocalSources` | The list of [local sources](https://filestack.github.io/filestack-ios/Classes/LocalSource.html) available to Filestack's picker.| `[.camera, .photoLibrary, .documents]` |

### Border Module

#### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Color | Allows user to select a border color | None | `commands` |
| Width | Allows user to select a border width | None | `commands` |
| Transparency | Allows user to set the border transparency amount | None | `commands` |

## Enabling or Disabling Modules

Modules may be enabled or disabled programmatically. Let's see an example:

1. Defining the available modules

    ```swift
    modules.all = [
        modules.transform,
        modules.filters,
        modules.adjustments
    ]
    ```

## Enabling or Disabling Module Features

Module features may be enabled or disabled programmatically. Let's see a few examples:

1. Allow only circle crop in transform module

    ```swift
    modules.transform.cropCommands = [
        Modules.Transform.Commands.Crop(type: .none),
        Modules.Transform.Commands.Crop(type: .circle)
    ]
    ```

2. Disable extra commands in transform module

    ```swift
    modules.transform.extraCommands = []
    ```

3. Define custom crop modes in transform module

    ```swift
    // Keep original ratio
    modules.transform.cropCommands.append(
        Modules.Transform.Commands.Crop(type: .rect, aspectRatio: .original)
    )

    // Keep 16:9 ratio
    modules.transform.cropCommands.append(
        Modules.Transform.Commands.Crop(type: .rect, aspectRatio: .custom(CGSize(width: 16, height: 9)))
    )
    ```

4. Define available filters in filters module
    ```swift
    modules.filters.commands = [
        Modules.Filters.Commands.Filter(type: .chrome),
        Modules.Filters.Commands.Filter(type: .process),
        Modules.Filters.Commands.Filter(type: .instant)
    ]
    ```

5. Add extra available font families in text module

    ```swift
    modules.text.availableFontFamilies.append(contentsOf: ["Optima Regular", "Symbol"])
    ```

    Or you may want to replace available font families completely:

    ```swift
    modules.text.availableFontFamilies = ["Optima Regular", "Symbol"]
    ```

6. Add stickers in stickers module

    **IMPORTANT**: *Make sure these stickers are first added to your project (e.g. as part of an **XCAsset**.)*

    ```swift
    modules.sticker.stickers = [
        "Funny": (1...18).compactMap { UIImage(named: "stickers-funny-\($0)") },
        "Hilarious": (1...18).compactMap { UIImage(named: "stickers-hilarious-\($0)") },
        "Extravagant": (1...18).compactMap { UIImage(named: "stickers-extravagant-\($0)") },
        "Kick-ass": (1...18).compactMap { UIImage(named: "stickers-kickass-\($0)") }
    ]
    ```

To discover other module features that may be configured, enabled or disabled, try Xcode's autocompletion on your `Modules` objects.

## Screenshots

| <img src="screenshots/1.png"> | <img src="screenshots/2.png"> | <img src="screenshots/3.png"> |
|---|---|---|
| <img src="screenshots/5.png"> | <img src="screenshots/6.png"> | <img src="screenshots/7.png"> |

## Demo

Check the [demo](https://github.com/filestack/transformations-ui-demo-ios) showcasing **Transformations UI** usage.

## Versioning

Transformations UI follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/transformations-ui-ios/issues).

## Credits

Thank you to all the [contributors](https://github.com/filestack/transformations-ui-ios/graphs/contributors).
