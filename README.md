# ObjRuby [![Build Status](https://github.com/keegnotrub/obj-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/keegnotrub/obj-ruby/actions?query=workflow%3Aci+branch%3Amain)

A fork of [GNUstep's RIGS](https://github.com/gnustep/libs-ruby), updated for modern verions of macOS and Ruby.

## Dependencies

- Ruby 2.7, 3.0, 3.1 or 3.2
- macOS 11, 12, or 13

## Getting Started

1. Install ObjRuby at the command prompt:

        $ gem install obj_ruby

2. At the command prompt, create a new ObjRuby application:

        $ objr new myapp

   where "myapp" is the application name.

3. Change directory to `myapp` and start the app:

        $ cd myapp
        $ objr start

   Run `objr help` for other options.

5. Follow the [getting started guide](docs/getting-started.md) to start developing your application.


## Credit

ObjRuby is a fork of [GNUstep's RIGS](https://github.com/gnustep/libs-ruby), which according to it's author/maintainer [Laurent Julliard](https://github.com/ljulliar):

>  was built in my spare time when my 3 children are in bed :-)

It's really a testimate to both Laurent and the Objective-C runtime in general that while much of the original code was written in 2001, an incredible amount of it runs unchanged over 20 years later on modern versions of macOS and Ruby.


## License

This project is Copyright © 2023 Ryan Krug and thoughtbot. It is free software, and may be redistributed under the terms specified in the [LICENSE](https://github.com/keegnotrub/obj-ruby/blob/main/LICENSE) file.
