# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class TempDirectoryHandler
  attr_reader :keep_tmpdir, :tmp_dir

  def initialize(keep_tmpdir=false, tmp_dir=nil)
    @keep_tmpdir = keep_tmpdir
    @tmp_dir = tmp_dir
    create_tmp_dir
  end

  def create_tmp_dir
    @tmp_dir = Dir.mktmpdir if @tmp_dir.nil?
    at_exit do
      delete_dir(@tmp_dir) unless @keep_tmpdir
    end
  end

  def delete_dir(tmp_dir)
    FileUtils.rm_rf(tmp_dir) if Dir.exists?(tmp_dir)
  end
end
