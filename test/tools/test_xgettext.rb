# -*- coding: utf-8 -*-
#
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
# Copyright (C) 2012  Haruka Yoshihara <yoshihara@clear-code.com>
#
# License: Ruby's or LGPL
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "gettext/tools/xgettext"

class TestToolsXGetText < Test::Unit::TestCase
  include GetTextTestUtils

  def setup
    @xgettext = GetText::Tools::XGetText.new
    @now = Time.parse("2012-08-19 18:10+0900")
    stub(@xgettext).now {@now}
  end

  setup :setup_tmpdir
  teardown :teardown_tmpdir

  setup
  def setup_paths
    @rb_file_path = File.join(@tmpdir, "lib", "xgettext.rb")
    @pot_file_path = File.join(@tmpdir, "po", "xgettext.pot")
    FileUtils.mkdir_p(File.dirname(@rb_file_path))
    FileUtils.mkdir_p(File.dirname(@pot_file_path))
  end

  def test_relative_source
    File.open(@rb_file_path, "w") do |rb_file|
      rb_file.puts(<<-EOR)
_("Hello")
EOR
    end

    @xgettext.run("--output", @pot_file_path, @rb_file_path)

    assert_equal(<<-EOP, File.read(@pot_file_path))
#{header}
#: ../lib/xgettext.rb:1
msgid "Hello"
msgstr ""
EOP
  end

  class TestCommandLineOption < self
    def test_package_name
      File.open(@rb_file_path, "w") do |rb_file|
        rb_file.puts(header)
      end

      package_name = "test-package"
      @xgettext.run("--output", @pot_file_path,
                    "--package-name", package_name,
                    @rb_file_path)

      options = {:package_name => package_name}
      expected_header = "#{header(options)}\n"
      assert_equal(expected_header, File.read(@pot_file_path))
    end

    def test_package_version
      File.open(@rb_file_path, "w") do |rb_file|
        rb_file.puts(header)
      end

      package_version = "1.2.3"
      @xgettext.run("--output", @pot_file_path,
                    "--package-version", package_version,
                    @rb_file_path)

      options = {:package_version => package_version}
      expected_header = "#{header(options)}\n"
      assert_equal(expected_header, File.read(@pot_file_path))
    end

    def test_report_msgid_bugs_to
      File.open(@rb_file_path, "w") do |rb_file|
        rb_file.puts(header)
      end

      msgid_bugs_address = "me@example.com"
      @xgettext.run("--output", @pot_file_path,
                    "--msgid-bugs-address", msgid_bugs_address,
                    @rb_file_path)

      options = {:msgid_bugs_address => msgid_bugs_address}
      expected_header = "#{header(options)}\n"
      assert_equal(expected_header, File.read(@pot_file_path))
    end

    def test_copyright_holder
      File.open(@rb_file_path, "w") do |rb_file|
        rb_file.puts(header)
      end

      copyright_holder = "me"
      @xgettext.run("--output", @pot_file_path,
                    "--copyright-holder", copyright_holder,
                    @rb_file_path)

      options = {:copyright_holder => copyright_holder}
      expected_header = "#{header(options)}\n"
      assert_equal(expected_header, File.read(@pot_file_path))
    end
  end

  private
  def header(options=nil)
    options ||= {}
    package_name = options[:package_name] || "PACKAGE"
    package_version = options[:package_version] || "VERSION"
    msgid_bugs_address = options[:msgid_bugs_address] || ""
    copyright_holder = options[:copyright_holder] ||
                         "THE PACKAGE'S COPYRIGHT HOLDER"

    time = @now.strftime("%Y-%m-%d %H:%M%z")
    <<-"EOH"
# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR #{copyright_holder}
# This file is distributed under the same license as the #{package_name} package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: #{package_name} #{package_version}\\n"
"Report-Msgid-Bugs-To: #{msgid_bugs_address}\\n"
"POT-Creation-Date: #{time}\\n"
"PO-Revision-Date: #{time}\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"Language: \\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"
"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n"
EOH
  end
end
