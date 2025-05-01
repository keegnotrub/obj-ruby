# ObjRuby [![Build Status](https://github.com/keegnotrub/obj-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/keegnotrub/obj-ruby/actions?query=workflow%3Aci+branch%3Amain)

A fork of [GNUstep's RIGS](https://github.com/gnustep/libs-ruby), updated for modern verions of macOS and Ruby.

## Requirements

- Ruby 3.2, 3.3, or 3.4 (macOS's default, Ruby 2.6.10, is also supported)
- macOS 13, 14, or 15

## Installation

Be sure you have Xcode Command Line Tools installed

    $ xcode-select --install

Then you can run: 

    $ sudo gem install obj_ruby

Or you can include in your Gemfile:

```ruby
gem 'obj_ruby', '~> 0.1'
```

## Usage

ObjRuby imports Objective-C classes dynamically at runtime. As an example, here is how you can import the `NSDate` class into Ruby's namespace by using the [Foundation framework](https://developer.apple.com/documentation/foundation?language=objc).

``` ruby
require "obj_ruby"
require "obj_ruby/foundation"

date = ObjRuby::NSDate.dateWithTimeIntervalSince1970(42424242)
other_date = date.addTimeInterval(1000)
earlier_date = date.earlierDate(other_date)
```

Note you are allowed to mix some Ruby and Objective-C types. Ruby's `String`, `Array`, `Hash`, `Time`, and `Numeric` classes bridge to Objective-C's `NSString`, `NSArray`, `NSDictionary`, `NSDate`, and `NSNumber` classes automatically.

``` ruby
require "obj_ruby"
require "obj_ruby/foundation"

dict = ObjRuby::NSMutableDictionary.new
dict.setObject_forKey(Time.now, "Hello!")
```
Other frameworks, like the [AppKit framework](https://developer.apple.com/documentation/appkit?language=objc) for graphical user interfaces, are also supported.

``` ruby
require "obj_ruby"
require "obj_ruby/app_kit"

app = ObjRuby::NSApplication.sharedApplication
app.setActivationPolicy ObjRuby::NSApplicationActivationPolicyRegular
app.activateIgnoringOtherApps(true)

alert = ObjRuby::NSAlert.new
alert.setMessageText("Hello world!")
alert.runModal
```

For more examples, see this projects [spec](https://github.com/keegnotrub/obj-ruby/tree/main/spec) folder.

## Credit

ObjRuby is a fork of [GNUstep's RIGS](https://github.com/gnustep/libs-ruby), which according to it's author/maintainer [Laurent Julliard](https://github.com/ljulliar):

>  was built in my spare time when my 3 children are in bed :-)

It's really a testimate to both Laurent and the Objective-C runtime in general that while much of the original code was written in 2001, an incredible amount of it runs unchanged over 20 years later on modern versions of macOS and Ruby.

## License

This project is Copyright © 2025 Ryan Krug. It is free software, and may be redistributed under the terms specified in the [LICENSE](https://github.com/keegnotrub/obj-ruby/blob/main/LICENSE) file.
