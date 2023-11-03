require "obj_ruby/version"
require "fileutils"
require "thor"
require "pathname"

module ObjRuby
  class Commands < Thor
    include Thor::Actions

    package_name "ObjRuby"

    def self.generator?
      ENV["OBJR_ROOT"].nil?
    end

    def self.runner?
      !generator?
    end

    def self.exit_on_failure?
      false
    end

    map ["-v", "--version"] => :version
    desc "version", "Show ObjRuby version"
    def version
      say "ObjRuby #{ObjRuby::VERSION}"
    end

    desc "new APP_PATH", "creates a new ObjRuby macOS application at APP_PATH", hide: runner?
    def new(path)
      self.destination_root = File.expand_path(path, destination_root)
      source_paths << File.expand_path("../../templates/mac", __dir__)

      in_root do
        template("Gemfile")
        directory("app")
        directory("bin")
        chmod("bin/objr", "+x")
        directory("config")
        create_file("lib/.keep")
        copy_file("gitignore", ".gitignore")
        template("ruby-version", ".ruby-version")

        run("git init -b main")

        require "bundler"
        Bundler.with_original_env do
          system(Gem.ruby, Gem.bin_path("bundler", "bundle"), "install")
        end
      end
    end

    map ["s"] => :start
    desc "start", "Runs the ObjRuby application", hide: generator?
    def start
      self.destination_root = ENV["OBJR_ROOT"]

      in_root do
        system(Gem.ruby, "config/boot.rb")
      end
    end

    map ["c"] => :console
    desc "console", "Runs the ObjRuby IRB console", hide: generator?
    def console
      self.destination_root = ENV["OBJR_ROOT"]

      in_root do
        system(Gem.ruby, "config/console.rb")
      end
    end

    map ["p"] => :package
    desc "package", "Packages the ObjRuby macOS application into /pkg", hide: generator?
    option :use_system_ruby, type: :boolean, default: false
    def package
      self.destination_root = ENV["OBJR_ROOT"]
      source_paths << File.expand_path("../../templates/mac-app", __dir__)

      in_root do
        remove_dir(resources_dir)
        directory("pkg")
        inside macos_dir do
          chmod(app_slug, "+x")
        end
        source_paths << ENV["OBJR_ROOT"]
        `git ls-files`.split("\n").each do |file|
          copy_file(file, File.expand_path(file, resources_dir))
        end
        inside resources_dir do
          require "bundler"
          Bundler.with_original_env do
            system(Gem.ruby, Gem.bin_path("bundler", "bundle"), "package")
          end
        end
      end
    end

    private

    def app_name
      app_dir.gsub(/[\W\-_]/, "_").squeeze("_").split("_").map(&:capitalize).join(" ")
    end

    def app_slug
      app_dir.gsub(/[\W\-_]/, "_").squeeze("_").split("_").map(&:capitalize).join("-")
    end

    def macos_dir
      "pkg/#{app_name}.app/Contents/MacOS"
    end

    def resources_dir
      "pkg/#{app_name}.app/Contents/Resources"
    end

    def app_dir
      File.basename(ENV["OBJR_ROOT"] || destination_root)
    end
  end
end
