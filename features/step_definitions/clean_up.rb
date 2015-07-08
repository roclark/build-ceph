Then /^the temporary directory should (not )?exist$/ do |expect_match|
  puts File.exist?(TMP_DIR)
  if expect_match
    expect(File.exist?(TMP_DIR)).to match(false)
  else
    expect(File.exist?(TMP_DIR)).to match(true)
  end
end
