require 'listen'

APPLE_BOOK_ANNOTATION_PATH = "/Users/altheralves/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation/"
# filenames = %w(AEAnnotation_v10312011_1727_local.sqlite)
# listen_regex = /(?:#{file.map { |f| Regexp.quote(f) } * '|'})$/

# listener = Listen.to(APPLE_BOOK_ANNOTATION_PATH, only: /\AEAnnotation_v10312011_1727_local.sqlite$/) do |modified, added, removed|
listener = Listen.to(APPLE_BOOK_ANNOTATION_PATH) do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)
end
listener.start
sleep