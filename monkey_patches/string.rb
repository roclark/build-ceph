# (C) Copyright 2015 Hewlett-Packard Development Company, L.P.
# All rights reserved

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min_by(&:size).size || 0
    gsub(/^[\t]{#{indent}}/,'').chomp
  end
end
