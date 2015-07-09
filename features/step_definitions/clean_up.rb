Then /^the temporary directory should (not )?exist$/ do |expect_match|
  expect(File.exist?(TMP_DIR)).not_to eql(expect_match)
end
