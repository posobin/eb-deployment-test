(ns posobin.eb-deployment-test
  (:require
    [ring.adapter.jetty :as jetty]
    [libpython-clj.python :refer [py.-] :as py]
    [cprop.core :refer [load-config]])
  (:gen-class))

(def config (load-config))

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
  #_(when (:prod config)
      (py/initialize! :python-executable "virtualenv/bin/python3"))
  ((requiring-resolve 'libpython-clj.require/require-python) 'requests)
  (println (-> ((requiring-resolve 'requests/get) "https://ya.ru"
                {"Accept-Encoding" "identity"})
             (py.- :headers)))
  (println "Serving on port" (config :port 3000))
  (jetty/run-jetty handler {:port (config :port 3000)}))
