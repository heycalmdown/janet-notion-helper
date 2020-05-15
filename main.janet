(import http)
(import json)

(defn id->dash [id]
  (string/join [(slice id 0 8)
                (slice id 8 12)
                (slice id 12 16)
                (slice id 16 20)
                (slice id 20)] "-"))

# function dashToId(id) {
#   return id.replace(/-/g, '');
# }

(defn req->loadPageChunk [pageId] 
  (string (json/encode @{ :pageId pageId :limit 20 :chunkNumber 0 :verticalColumns false })))

(defn req->queryCollection [ids] 
  (string (json/encode @{ :collectionId (first ids) :collectionViewId (get ids 1) :loader @{ :limit 500 :type "table" } })))

(defn headers [token] (merge {"cookie" (string "token_v2=" token)} {
  "accept" "*/*"
  "accept-language" "en-US:en;q=0.9"
  "origin" "https://www.notion.so"
  "referer" "https://www.notion.so"
  "user-agent" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
  # "accept-encoding" "gzip"
  "content-type" "application/json"
}))

(defn loadPageChunk! [token tableId] 
  (json/decode ((http/post "https://www.notion.so/api/v3/loadPageChunk" (req->loadPageChunk (id->dash tableId)) :headers (headers token)) :body))
)

(defn queryCollection! [token ids] 
  (json/decode ((http/post "https://www.notion.so/api/v3/queryCollection" (req->queryCollection ids) :headers (headers token)) :body))
)

(defn collection-ids [obj]
  [
    (-> (get obj "recordMap") (get "collection") (keys) (first))
    (-> (get obj "recordMap") (get "collection_view") (keys) (first))
  ]
)

(defn collection-blocks [obj] (-> obj (get "recordMap") (get "block")))

(defn title [block] (-?> block (get "value") (get "properties") (get "title") (get 0) (get 0)))

(defn main [&]
  (let [env (os/environ)
    NOTION_TOKEN (get env "NOTION_TOKEN")
    TABLEID (get env "TABLEID")]
    (->> (loadPageChunk! NOTION_TOKEN TABLEID)
      (collection-ids)
      (queryCollection! NOTION_TOKEN)
      (collection-blocks)
      (values)
      (map title)
      (filter (comp not nil?))
      (map print)
      # (length)
    )))
