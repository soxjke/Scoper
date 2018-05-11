# Scoper

[![CI Status](http://img.shields.io/travis/soxjke/Scoper.svg?style=flat)](https://travis-ci.org/soxjke/Scoper)
[![Version](https://img.shields.io/cocoapods/v/Scoper.svg?style=flat)](http://cocoapods.org/pods/Scoper)
[![License](https://img.shields.io/cocoapods/l/Scoper.svg?style=flat)](http://cocoapods.org/pods/Scoper)
[![Platform](https://img.shields.io/cocoapods/p/Scoper.svg?style=flat)](http://cocoapods.org/pods/Scoper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Scoper is designed with Swift 4 API in mind

## Installation

Scoper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Scoper'
```

## Usage

Scoper API is designed to be familiar for everybody who tried BDD testing frameworks like [Kiwi](https://github.com/kiwi-bdd/Kiwi) or [Quick](https://github.com/Quick/Quick)

Use Scoper by creating ```Scope``` instances and scheduling them via ```TestRunner```

Basic usage:

```swift
let scope = DefaultScope.Builder()
	.name("My scope")
	.options(TestOptions.basic)
	.testCase { context, completion in
		//
		// run worker instructions here
		//
	}
	.build() 
```

```Builder``` for ```Scope``` has following methods:

```name``` - to set human-readable name for scope

```options``` - to set measurement and logging options for scope, ```TestOptions``` struct

```before``` - block to execute before the scope

```beforeEach``` - block to execute before each worker run for each test case

```after``` - block to execute after the scope

```afterEach``` - block to execute after each worker run for each test case

```testCase``` - to append test case

```nestedScope``` - to add nested scope

Despite there're shorthand methods for creating ```TestCase```, it has it's own functional builder:

```name``` - to set human-readable name for worker

```async``` - to set whether worker is expected to work asynchronously. ```completion()``` should be called in worker in this 
case. Default value is ```false```

```worker``` - worker block

```numberOfRuns``` - to set number of runs. Default value is 10

```timeout``` - to set timeout value for worker. It is measured from calling ```worker``` until call of ```completion```. Default value is 60s

```entryPointQueue``` - to set entry point queue for worker. Default is ```DispatchQueue.main```

```TestOptions``` values:

```runTime``` - measure worker run time
```cpuTime``` - measure CPU usage of measured process
```hostCpuTime``` - measure CPU usage of target device
```memoryFootprint``` - measure memory usage of worker
```diskUsage``` - measure disk reads and writes of process
```frameRate``` - measure device frame rate (on iOS)
```logProgress``` - use logging of each scope / worker start and complete
```logResults``` - log performance results
```basic``` - runTime, logProgress and logResults
```complete``` - all options included

More usage examples can be found [here](https://github.com/soxjke/Scoper/blob/master/Algorithms/Algorithms/main.swift) and [here](https://github.com/soxjke/Scoper/blob/master/Example/Scoper/AppDelegate.swift)

## Author

soxjke, soxjke@gmail.com

## License

Scoper is available under the MIT license. See the LICENSE file for more info.
