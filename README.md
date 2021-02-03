# Transformations UI

Filestack's [Transformations UI](https://www.filestack.com/docs/transformations/ui/) implementation for iOS and iPadOS.

**Transformations UI** is shipped as a Swift Package and contains Standard and Premium modules.

## Requirements

* Xcode 12+
* Swift 4.2+ / Objective-C
* iOS 11.0+ / iPadOS 13.0+

## Installation

To install our Swift Package, please follow the steps below:

- Add `https://github.com/filestack/transformations-ui-ios.git` as a [Swift Package Manager](https://swift.org/package-manager/) dependency to your project.
- When asked to **Choose Package Options**, use the default settings provided by Xcode.
- When asked to **Add Package**, toggle on all the packages displayed (at the time of writting these were `Pikko`, `TransformationsUI`, `TransformationsUIPremiumAddOns`, `TransformationsShared`, and `UberSegmentedControl`.) and choose the target you would like to add them to on each of them.

## Usage

### Using TransformationsUI with Standard Modules

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

### Using TransformationsUI with Premium Modules

1. Import `TransformationsUIPremiumAddOns`

    ```swift
    import TransformationsUI
    import TransformationsUIPremiumAddOns /* newly added */
    ```

2. Get your **Filestack API key** ready, you will need it for next step.

3. Instantiate `TransformationsUI` using a custom `Config` object

    ```swift
    let config: Config

    do {
        let modules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

        config = Config(modules: modules)
    } catch {
        // Unable to instantiate `PremiumModules`.
        //
        // You may want to double-check that your Filestack account has permissions
        // to use Transformations UI for the API key you have used above.
        //
        // Falling back to `StandardModules`.
        config = Config(modules: StandardModules())
    }

    let transformationsUI = TransformationsUI(with: config)
    ```

After that, you may follow the same steps as in the previous section (e.g., set and implement delegate, present view controller, etc.)

## Modules Features

Below you will find an exhaustive list of configurable properties and commands per module.

### Standard Modules

#### Transform Module

##### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Rotate | Rotate image 90 degrees clockwise | None | `extraCommands` |
| Crop | |  | `cropCommands` |
|      | Crop image freely (no constraints) | `type: .rect` | `cropCommands` |
|      | Circle crop image | `type: .circle` | `cropCommands` |

### Premium Modules

#### Transform Module

##### Commands

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

#### Filters Module

##### Commands

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

#### Adjustments Module

##### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Blur | Applies gaussian blur to image *(interactive)* | None | `commands` |
| Brightness | Allows adjusting image brightness *(interactive)* | None | `commands` |
| Contrast | Allows adjusting image contrats *(interactive)* | None | `commands` |
| Gamma | Allows adjusting RGB gamma components separately *(interactive)*  | None | `commands` |
| Hue | Allows adjusting image hue 360 degrees *(interactive)* | None | `commands` |

#### Text Module

##### Properties

| Property | Purpose | Example |
|---|---|---|
| `availableFontFamilies` | Defines the list of font families available in the editor | `["Courier", "Futura", "Helvetica", "Times New Roman"]`|
| `defaultFontFamily` | Defines the default font family | `"Helvetica"`|
| `defaultFontColor` | Defines the default font color | `.white`|
| `defaultFontStyle` | Defines the default font style | `[.bold, .underline]`|
| `defaultTextAlignment` | Defines the default text alignment | `.left`|

##### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| SelectFontFamily | Allows user to select a font family amongst families listed in `availableFontFamilies` | None | `commandsInGroups` |
| SelectFontColor | Allows user to select a font color | None | `commandsInGroups` |
| SelectFontStyle | Allows user to toggle font style options (`.bold`, `.italic`, `.underline`) | None | `commandsInGroups` |
| SelectTextAlignment | Allows user to select text alignment (`.left`, `.center`, `.right`, `.justified`)  | None | `commandsInGroups` |

#### Stickers Module *(added in 1.1)*

##### Properties

| Property | Purpose | Example |
|---|---|---|
| `stickers` | Defines the available stickers grouped by stickerset | `["Stickerset 1": [UIImage, UIImage], "Stickerset 2": [UIImage, UIImage]]`|

#### Overlays Module *(added in 1.1.3)*

##### Properties

| Property | Purpose | Example |
|---|---|---|
| `filestackAPIKey` | Filestack's API key required to pick images using Filestack's picker.| `"YOUR-API-KEY-HERE"` |
| `filestackAppSecret` | Filestack's APP secret required to pick images using Filestack's picker.| `"YOUR-APP-SECRET"` |
| `callbackURLScheme` | Required by Filestack's picker to complete the cloud provider's authentication flow (only required if any cloud sources are available.)| `"transformationsuidemo"` |
| `availableCloudSources` | The list of [cloud sources](https://filestack.github.io/filestack-ios/Classes/CloudSource.html) available to Filestack's picker.| `[.dropbox, .googleDrive, .googlePhotos]` |
| `availableLocalSources` | The list of [local sources](https://filestack.github.io/filestack-ios/Classes/LocalSource.html) available to Filestack's picker.| `[.camera, .photoLibrary, .documents]` |

#### Border Module

##### Commands

| Command | Purpose | Options | Group |
|---|---|---|----|
| Color | Allows user to select a border color | None | `commands` |
| Width | Allows user to select a border width | None | `commands` |
| Transparency | Allows user to set the border transparency amount | None | `commands` |

## Enabling or Disabling Modules

Modules may be enabled or disabled programmatically. Let's see an example:

1. Defining the available premium modules.

    ```swift
    let premiumModules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

    premiumModules.all = [
        premiumModules.transform,
        premiumModules.filters,
        premiumModules.adjustments
    ]
    ```

## Enabling or Disabling Module Features

Module features may be enabled or disabled programmatically. Let's see a few examples:

1. When using `StandardModules`, you want to allow circle cropping but disallow rect cropping.

    ```swift
    let standardModules = StandardModules()

    standardModules.transform.cropCommands = [
        StandardModules.Transform.Commands.Crop(type: .none),
        StandardModules.Transform.Commands.Crop(type: .circle)
    ]
    ```

2. When using `StandardModules`, you don't want any extra commands (e.g. rotation) to be available.

    ```swift
    let standardModules = StandardModules()

    standardModules.transform.extraCommands = []
    ```

3. When using `PremiumModules`, you want to define custom crop modes.

    ```swift
    let premiumModules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

    // Keep original ratio
    premiumModules.transform.cropCommands.append(
        PremiumModules.Transform.Commands.Crop(type: .rect, aspectRatio: .original)
    )

    // Keep 16:9 ratio
    premiumModules.transform.cropCommands.append(
        PremiumModules.Transform.Commands.Crop(type: .rect, aspectRatio: .custom(CGSize(width: 16, height: 9)))
    )
    ```

4. When using `PremiumModules`, you want to redefine the available filters in filters module.
    ```swift
    let premiumModules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

    premiumModules.filters.commands = [
        PremiumModules.Filters.Commands.Filter(type: .chrome),
        PremiumModules.Filters.Commands.Filter(type: .process),
        PremiumModules.Filters.Commands.Filter(type: .instant)
    ]
    ```

5. When using `PremiumModules`, you want to add extra available font families to text module.

    ```swift
    let premiumModules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

    premiumModules.text.availableFontFamilies.append(contentsOf: ["Optima Regular", "Symbol"])
    ```

    Or you may want to replace available font families completely:

    ```swift
    premiumModules.text.availableFontFamilies = ["Optima Regular", "Symbol"]
    ```

6. When using `PremiumModules`, you want to add stickers to stickers module.

    **IMPORTANT**: *Make sure these stickers are first added to your project (e.g. as part of an **XCAsset**.)*

    ```swift
    let premiumModules = try PremiumModules(apiKey: "YOUR-API-KEY-HERE")

    premiumModules.sticker.stickers = [
        "Funny": (1...18).compactMap { UIImage(named: "stickers-funny-\($0)") },
        "Hilarious": (1...18).compactMap { UIImage(named: "stickers-hilarious-\($0)") },
        "Extravagant": (1...18).compactMap { UIImage(named: "stickers-extravagant-\($0)") },
        "Kick-ass": (1...18).compactMap { UIImage(named: "stickers-kickass-\($0)") }
    ]
    ```

To discover other module features that may be configured, enabled or disabled, try Xcode's autocompletion with your `StandardModules` or `PremiumModules` objects.

## Screenshots

| <img src="screenshots/1.png"> | <img src="screenshots/2.png"> | <img src="screenshots/3.png"> |
|---|---|---|
| <img src="screenshots/5.png"> | <img src="screenshots/6.png"> | <img src="screenshots/7.png"> |

## Demo

Check the [demos](https://github.com/filestack/transformations-ui-demo-ios) showcasing using **Transformations UI** with either **Standard** or **Premium modules**.

## Versioning

Transformations UI follows the [Semantic Versioning](http://semver.org/).

## Issues

If you have problems, please create a [Github Issue](https://github.com/filestack/transformations-ui-ios/issues).

## Credits

Thank you to all the [contributors](https://github.com/filestack/transformations-ui-ios/graphs/contributors).
