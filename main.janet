(import http)
(import json)

(defn id->dash [id]
  (string/join [(slice id 0 8)
                (slice id 8 12)
                (slice id 12 16)
                (slice id 16 20)
                (slice id 20)] "-"))

(defn dash->id [dashed] (string/replace-all "-" "" dashed))

(defn stringify [ds] (string (json/encode ds)))

(defn req->loadPageChunk [page-id] (stringify @{ :pageId page-id :limit 20 :chunkNumber 0 :verticalColumns false }))

(defn req->queryCollection [ids] (stringify @{ :collectionId (first ids) :collectionViewId (get ids 1) :loader @{ :limit 500 :type "table" } }))

(defn headers [token] {
  "accept" "*/*"
  "accept-language" "en-US:en;q=0.9"
  "cookie" (string "token_v2=" token)
  "origin" "https://www.notion.so"
  "referer" "https://www.notion.so"
  "user-agent" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
  # "accept-encoding" "gzip"
  "content-type" "application/json"
})

(defn assert-200 [res] (if (= (res :status) 200) res (assert false (res :body))))

(defn post! [token api body] (->
  (http/post (string "https://www.notion.so/api/v3/" api) body :headers (headers token))
  (assert-200)
  (get :body)
  (json/decode)))

(defn loadPageChunk! [token page-id] (post! token "loadPageChunk" (req->loadPageChunk page-id)))

(defn queryCollection! [token ids] (post! token "queryCollection" (req->queryCollection ids)))

(defn collection-ids [obj]
  (let [record-map (get obj "recordMap")] [
    (-> record-map (get "collection") (keys) (first))
    (-> record-map (get "collection_view") (keys) (first))
  ]))

(defn collection-blocks [obj] (-> obj (get "recordMap") (get "block")))

(defn title [block] (-?> block (get "value") (get "properties") (get "title") (get 0) (get 0)))

(defn main [&]
  (let [env (os/environ)
    NOTION_TOKEN (get env "NOTION_TOKEN")
    PAGE_ID (get env "PAGE_ID")]
    (->> (loadPageChunk! NOTION_TOKEN (id->dash PAGE_ID))
      (collection-ids)
      (queryCollection! NOTION_TOKEN)
      (collection-blocks)
      (values)
      (map title)
      (filter (comp not nil?))
      (map print)
    )))
