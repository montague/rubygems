require 'rubygems/test_case'
require 'rubygems/installer'

class Gem::Installer

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :bin_dir

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :gem_dir

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :force

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :format

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :gem_home

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :env_shebang

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :ignore_dependencies

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :format_executable

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :security_policy

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :spec

  ##
  # Available through requiring rubygems/installer_test_case

  attr_writer :wrappers
end

##
# A test case for Gem::Installer.
#--
# TODO document these utility methods

class Gem::InstallerTestCase < Gem::TestCase

  def setup
    super

    @spec = quick_gem 'a' do |spec|
      util_make_exec spec
    end

    @user_spec = quick_gem 'b' do |spec|
      util_make_exec spec
    end

    util_build_gem @spec
    util_build_gem @user_spec

    @gem = @spec.cache_file
    @user_gem = @user_spec.cache_file

    @installer      = util_installer @spec, @gemhome
    @user_installer = util_installer @user_spec, Gem.user_dir, :user
  end

  def util_gem_bindir spec = @spec
    # TODO: deprecate
    spec.bin_dir
  end

  def util_gem_dir spec = @spec
    # TODO: deprecate
    spec.gem_dir
  end

  def util_inst_bindir
    File.join @gemhome, "bin"
  end

  def util_make_exec(spec = @spec, shebang = "#!/usr/bin/ruby")
    spec.executables = %w[executable]
    spec.files << 'bin/executable'

    exec_path = spec.bin_file "executable"
    write_file exec_path do |io|
      io.puts shebang
    end

    bin_path = File.join @tempdir, "bin", "executable"
    write_file bin_path do |io|
      io.puts shebang
    end
  end

  def util_setup_gem(ui = @ui) # HACK fix use_ui to make this automatic
    @spec.files << File.join('lib', 'code.rb')
    @spec.extensions << File.join('ext', 'a', 'mkrf_conf.rb')

    Dir.chdir @tempdir do
      FileUtils.mkdir_p 'bin'
      FileUtils.mkdir_p 'lib'
      FileUtils.mkdir_p File.join('ext', 'a')
      File.open File.join('bin', 'executable'), 'w' do |f| f.puts '1' end
      File.open File.join('lib', 'code.rb'), 'w' do |f| f.puts '1' end
      File.open File.join('ext', 'a', 'mkrf_conf.rb'), 'w' do |f|
        f << <<-EOF
          File.open 'Rakefile', 'w' do |rf| rf.puts "task :default" end
        EOF
      end

      use_ui ui do
        FileUtils.rm_f @gem

        @gem = Gem::Package.build @spec
      end
    end

    @installer = Gem::Installer.new @gem
  end

  def util_installer(spec, gem_home, user=false)
    Gem::Installer.new(spec.cache_file,
                       :install_dir => gem_home,
                       :user_install => user)
  end
end
