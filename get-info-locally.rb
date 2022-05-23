require "sqlite3"
require "pathname"
require "json"

APPLE_BOOK_ANNOTATION_PATH = "/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation/AEAnnotation_v10312011_1727_local.sqlite"
APPLE_BOOK_LIBRARY_PATH = "/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary/BKLibrary-1-091020131601.sqlite"

def get(path, sql, object)
  path = File.expand_path('~') + path
  db = SQLite3::Database.new path

  result = []
  db.execute(sql) do |row|
    obj = object.new(*row)
    result << obj.to_h
  end
  result
end


SELECT_ANNOTATION=<<~SQL
  SELECT
    ZANNOTATIONASSETID AS BOOK_ID,
    ZFUTUREPROOFING5 AS CHAPTER,
    ZANNOTATIONSELECTEDTEXT AS TEXT,
    ZANNOTATIONREPRESENTATIVETEXT AS SENTENCE,
    ZANNOTATIONNOTE AS NOTE,
    ZANNOTATIONLOCATION AS PATH,
    ZANNOTATIONCREATIONDATE AS CREATED_AT,
    ZANNOTATIONMODIFICATIONDATE AS UPDATED_AT,
    ZANNOTATIONISUNDERLINE AS IS_INDERLINE,
    ZANNOTATIONSTYLE AS COLOR,
    ZANNOTATIONTYPE AS TYPE
  FROM ZAEANNOTATION
  WHERE ZANNOTATIONDELETED = 0
SQL

Annotation = Struct.new(:book_id, :chapter, :text, :sentence, :note, :path, :created_at, :updated_at, :is_inderline, :color, :type)
annotations = get(APPLE_BOOK_ANNOTATION_PATH, SELECT_ANNOTATION, Annotation)


SELECT_LIBRARY=<<-SQL
  SELECT 
    ZASSETID AS BOOK_ID,
    ZAUTHOR AS AUTHOR, 
    ZTITLE AS TITLE,
    ZLASTENGAGEDDATE AS LAST_ENGAGED_DATE,
    ZREADINGPROGRESS AS READING_PROGRESS, 
    ZISFINISHED AS MARKED_AS_FINISHED, 
    ZPURCHASEDATE AS PURCHASE_DATE, 
    ZGENRE AS GENRE, 
    ZLANGUAGE AS LANG, 
    ZFILESIZE AS FILE_SIZE,
    ZPAGECOUNT AS PAGE_COUNT,
    ZCREATIONDATE AS CREATED_AT,
    ZMODIFICATIONDATE AS UPDATED_AT,
    ZASSETDETAILSMODIFICATIONDATE AS ASSET_DETAILS_MODIFICATION_DATE
  FROM ZBKLIBRARYASSET
SQL

Library = Struct.new(
  :book_id,
  :author,
  :title,
  :last_engaged_date,
  :reading_progress,
  :marked_as_finished,
  :purchase_date,
  :genre,
  :lang,
  :file_size,
  :page_count,
  :created_at,
  :updated_at,
  :asset_details_modification_date
)
libraries = get(APPLE_BOOK_LIBRARY_PATH, SELECT_LIBRARY, Library)

# libraries.map{|i| i[:title]}.each{|i| puts i}
# exit(0)


# DOC: Joins Annotation with Library by book_id
# result = annotations.map{|i1| {**i1, **(libraries.find{|i2| i2[:book_id]==i1[:book_id]} || {}) }}
result = libraries.map{|i1| {**i1, **(annotations.find{|i2| i2[:book_id]==i1[:book_id]} || {}) }}
# result.each do |item|
#   p item
# end
# File.write("annota.json", result.to_json)
File.write("annota.json", JSON.pretty_generate(result))

# TODO: Send final JSON to Github Gist
# const TOKEN = "YOUR_PERSONAL_ACCESS_TOKEN";
# const GIST_ID = "YOUR_GIST_ID";
# const GIST_FILENAME = "db.json";
# /* 
#  * Puts the data you want to store back into the gist
#  */
# async function setData(data) {
#   const req = await fetch(`https://api.github.com/gists/${GIST_ID}`, {
#     method: "PATCH",
#     headers: {
#       Authorization: `Bearer ${TOKEN}`,
#     },
#     body: JSON.stringify({
#       files: {
#         [GIST_FILENAME]: {
#           content: JSON.stringify(data),
#         },
#       },
#     }),
#   });
#   return req.json();
# }