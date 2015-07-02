Then /^the temporary directory should be removed$/ do
  expect(File).not_to be_directory(TMP_DIR)
end
