# ObjRuby [![Build Status](https://github.com/keegnotrub/obj-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/keegnotrub/obj-ruby/actions?query=workflow%3Aci+branch%3Amain)

A fork of [GNUStep's RIGS](https://github.com/gnustep/libs-ruby), updated for modern verions of macOS and Ruby.

## Dependencies

- Ruby 2.7, 3.0, 3.1 or 3.2
- macOS 11, 12, or 13

## Installation

You can run: 

    $ gem install obj_ruby

Or you can include in your Gemfile:

```ruby
gem 'obj_ruby', '~> 1.0'
```

## Usage

ObjRuby imports Objective-C classes dynamically at runtime. As an example, here is how you can import the `NSDate` class into Ruby's namespace (for more examples, see this projects [spec](https://github.com/keegnotrub/obj-ruby/tree/main/spec) folder):

``` ruby
ObjRuby.import("NSDate")

date = NSDate.dateWithTimeIntervalSince1970(42424242)
other_date = date.addTimeInterval(1000)
earlier_date = date.earlierDate(other_date)
```

Oftentimes you'll want to import all of a particular framework like [Foundation](https://developer.apple.com/documentation/foundation?language=objc) or [AppKit](https://developer.apple.com/documentation/appkit?language=objc). ObjRuby provides convenience requires for each:

``` ruby
require "foundation"

dict = NSMutableDictionary.new
dict.setObject_forKey(NSDate.new, "Hello!")
```

``` ruby
require "app_kit"

app = NSApplication.sharedApplication
app.setActivationPolicy NSApplicationActivationPolicyRegular
app.activateIgnoringOtherApps(true)

alert = NSAlert.new
alert.setMessageText("Hello world!")
alert.runModal
```

## Future

- Support variable argument lists in Objective-C such as `NSString#stringWithFormat`, `NSArray#arrayWithObjects` and `NSLog`.
- Using Ruby's procs to bridge to Objective-C blocks

## Credit

ObjRuby is a fork of [GNUStep's RIGS](https://github.com/gnustep/libs-ruby), which according to it's author/maintainer [Laurent Julliard](https://github.com/ljulliar):

>  was built in my spare time when my 3 children are in bed :-)

It's really a testimate to both Laurent and the Objective-C runtime in general that while much of the original code was written in 2001, an incredible amount of it runs unchanged over 20 years later on modern versions of macOS and Ruby.