require "obj_ruby/version"
require "obj_ruby/stubs"
require "obj_ruby/assets"
require "thor"

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
        directory("assets")
        chmod("bin/objr", "+x")
        directory("config")
        create_file("lib/.keep")
        create_file("pkg/.keep")
        create_file("tmp/.keep")
        copy_file("gitignore", ".gitignore")
        template("ruby-version", ".ruby-version")
        template("tool-versions", ".tool-versions")
        load_stubs
        load_assets
        directory("%app_name%.xcodeproj")

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
        puts("ObjRuby #{ObjRuby::VERSION} application starting")
        compile_xibs
        exec(Gem.ruby, "config/boot.rb")
      end
    end

    map ["c"] => :console
    desc "console", "Runs the ObjRuby IRB console", hide: generator?
    def console
      self.destination_root = ENV["OBJR_ROOT"]

      in_root do
        puts("ObjRuby #{ObjRuby::VERSION} console starting")
        compile_xibs
        exec(Gem.ruby, "config/console.rb")
      end
    end

    map ["e"] => :editor
    desc "editor", "Opens the ObjRuby Xcode project", hide: generator?
    def editor
      self.destination_root = ENV["OBJR_ROOT"]
      source_paths << File.expand_path("../../templates/mac", __dir__)

      in_root do
        load_stubs
        load_assets
        directory("%app_name%.xcodeproj", force: true)

        system("open", editor_dir)
      end
    end

    map ["p"] => :package
    desc "package", "Packages the ObjRuby macOS application into /pkg", hide: generator?
    option :use_system_ruby, type: :boolean, default: false
    def package
      self.destination_root = ENV["OBJR_ROOT"]
      source_paths << File.expand_path("../../templates/mac-app", __dir__)

      in_root do
        app_files = `git ls-files`.split("\n").map { |f| Pathname.new(f) }

        if app_files.empty?
          error("Please check files into git by running `git add --all` prior to running `objr package`")
          return
        end

        remove_dir(resources_dir)
        directory("pkg")
        inside macos_dir do
          chmod(app_slug, "+x")
        end
        source_paths << ENV["OBJR_ROOT"]
        app_files.each do |file|
          case file.extname
          when ".xib"
            nib = File.join(resources_dir, file.sub_ext(".nib"))
            say_status(:create, nib)
            system("ibtool #{file} --compile #{nib}")
          else
            copy_file(file, File.expand_path(file, resources_dir))
          end
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

    def load_stubs
      Pathname.glob("app/**/*.rb").each do |rb|
        stubs.append_file(rb)
      end
    end

    def load_assets
      Assets::SUPPORTED_TYPES.each_key do |ext|
        Pathname.glob("assets/**/*#{ext}").each do |asset|
          assets.append_file(asset)
        end
      end
    end

    def compile_xibs
      Pathname.glob("assets/**/*.xib").each do |xib|
        xib.sub_ext(".nib").tap do |nib|
          system("xcrun ibtool #{xib} --compile #{nib}")
        end
      end
    end

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

    def editor_dir
      "#{app_name}.xcodeproj"
    end

    def app_dir
      File.basename(ENV["OBJR_ROOT"] || destination_root)
    end

    def stubs
      @stubs ||= Stubs.new
    end

    def assets
      @assets ||= Assets.new
    end
  end
end
