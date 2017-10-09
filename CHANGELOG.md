# Change Log
All notable changes to this project will be documented in this file.
`WhereAmI` adheres to [Semantic Versioning](http://semver.org/).

## [5.0.0](https://github.com/lypiut/WhereAmI/releases/tag/5.0.0)

- Update to Swift 4

## [4.0.0](https://github.com/lypiut/WhereAmI/releases/tag/4.0.0)

- Swift 3 support
- Drop iOS 7 support

## [3.0.0](https://github.com/lypiut/WhereAmI/releases/tag/3.0.0)

Rewrite of the library in order to be more swift friendly and easy to use.

#### Added
- `LocationProfile` protocol allows you to create your custom location profile
- The `WhereAmI` and `whatIsThisPlace` methods have one closure for the response handling and the `locationRefusedHandler` has been removed. Responses are returned via an enum.

## [2.1.0](https://github.com/lypiut/WhereAmI/releases/tag/2.1.0)

#### Added
- Support of watchOS 2.0 and tvOS 9.0
- allowsBackgroundLocationUpdates is true when you request `AlwaysAuthorization`

## [2.0.0](https://github.com/lypiut/WhereAmI/releases/tag/2.0.0)

#### Added
- Support of iOS 9 and Swift 2.0
