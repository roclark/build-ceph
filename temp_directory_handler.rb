# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class TempDirectoryHandler
  attr_reader :tmp_dir

  def initialize
    @tmp_dir = nil
    process_cli_arguments
  end

  def process_cli_arguments
    OptionParser.new do |option|

      option.on('-t', '--tmpdir=<tmp-dir>', <<-EOS.strip_heredoc) do |tmp_dir|
          Use the specified temporary directory. Default is to use a randomly
          generated tmp directory.
          EOS
        @tmp_dir = tmp_dir
      end
    end.parse!

    @tmp_dir = Dir.mktmpdir if @tmp_dir.nil?
    at_exit do
      delete_dir(@tmp_dir) unless @keep_tmpdir
    end
  end

  def delete_dir(tmp_dir)
    FileUtils.rm_rf(tmp_dir) if Dir.exists?(tmp_dir)
  end
end
