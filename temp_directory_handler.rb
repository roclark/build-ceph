# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class TmpDir
  attr_reader :tmp_dir

  def initialize(keep_tmp_dir, tmp_dir)
    @keep_tmp_dir = keep_tmp_dir
    @tmp_dir = tmp_dir
    create_tmp_dir
  end

  def create_tmp_dir
    @tmp_dir = Dir.mktmpdir if @tmp_dir.nil?
    at_exit do
      delete_dir unless @keep_tmp_dir
    end
    return @tmp_dir
  end

  private

  def delete_dir
    FileUtils.rm_rf(@tmp_dir) if Dir.exists?(@tmp_dir)
  end
end
