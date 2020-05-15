(declare-project
    :name "notion-util" # required
    :description "my notion helper" # some example metadata.

    # Optional urls to git repositories that contain required artifacts.
    :dependencies ["json" "https://github.com/joy-framework/http"])

(declare-executable
    :name "booklist"
    :entry "main.janet")
