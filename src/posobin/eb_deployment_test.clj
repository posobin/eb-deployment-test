(ns posobin.eb-deployment-test
  (:require [ring.adapter.jetty :as jetty])
  (:gen-class))

(defn greet
  "Callable entry point to the application."
  [data]
  (println (str "Hello, " (or (:name data) "World") "!")))

(defn handler [_req]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Hello, world!"})

(defn -main
  "I don't do a whole lot ... yet."
  [& _args]
  (jetty/run-jetty handler {:port 3000}))
