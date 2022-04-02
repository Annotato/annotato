# Annotato

[![SwiftLint](https://github.com/Annotato/annotato/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/Annotato/annotato/actions/workflows/swiftlint.yml)
[![Swift Build](https://github.com/Annotato/annotato/actions/workflows/build.yml/badge.svg)](https://github.com/Annotato/annotato/actions/workflows/build.yml)

The following workflow was inspired from https://github.com/Dynavity/dynavity.

## Setting up XcodeGen

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate Xcode project files. As such, a prerequisite is to install XcodeGen.

1. Install XcodeGen

```sh
brew install XcodeGen
```

2. Create a copy of `Annotato/settings.yml.sample` named `Annotato/settings.yml`.

```sh
cp Annotato/settings.yml.sample Annotato/settings.yml
```

3. Open `Annotato/settings.yml` and replace `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` with your Team ID and a unique product bundle identifier respectively.
   One way to get your Team ID is by going to the Build settings in Xcode, choosing your team, then viewing the source file of `project.pbxproj`.

You can now generate your project settings by navigating to the directory containing `project.yml`, and executing `xcodegen`.

### Automating project files generation

To automate the process, the following githooks can be added so that the `xcodegen` command will be executed on checkouts / pulls.

Warning: The following commands will overwrite whatever githooks you previously had for `post-checkout` and `post-merge`.

Assuming you are at the root directory of the repository, execute the following commands:

```sh
echo -e '#!/bin/sh\ncd Annotato\nxcodegen --use-cache\npod install' > .git/hooks/post-checkout
```

```sh
chmod +x .git/hooks/post-checkout
```

```sh
echo -e '#!/bin/sh\ncd Annotato\nxcodegen --use-cache\npod install' > .git/hooks/post-merge
```

```sh
chmod +x .git/hooks/post-merge
```

## Setting up CocoaPods

[CocoaPods](https://github.com/CocoaPods/CocoaPods) is used to manage third-party dependencies such as Firebase.
Before opening the project in Xcode, run the following command in the project root directory (`Annotato/`).

```sh
sudo gem install cocoapods
```

```sh
pod install
```

Please take note of the following to avoid issues when building the project:

- Once `pod install` is done, do **not** re-run `xcodegen`. If you need to do so, re-run `pod install` after each `xcodegen`.
- Open the project in Xcode using only `Annotato.xcworkspace` and **not** `Annotato.xcodeproj`.
