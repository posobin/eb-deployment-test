FROM clojure:openjdk-11-tools-deps AS compile-image

WORKDIR /opt/build

COPY deps.edn .
RUN clojure -P -X:prod
RUN clojure -P -X:uberjar

COPY . .
RUN clojure -X:uberjar

# using buster because that's what the clojure image is based on
FROM openjdk:11-buster AS deploy-image

WORKDIR /opt/result

# We need libpython3-dev here for the libpython.so library that libpython-clj
# uses
RUN apt-get update && apt-get install --no-install-recommends --yes \
      python3-pip libpython3-dev

ENV JARFILE=eb-deployment-test.jar
# COPY --from=compile-image ${virtual_env_path} ${virtual_env_path}
COPY requirements.txt .
RUN pip3 install -r requirements.txt
# virtualenv doesn't work with libpython-clj for some reason.
# TODO: Figure out why.
# RUN python3 -mvenv ${virtual_env_path}

# ENV PATH="${virtual_env_path}/bin:$PATH"
COPY --from=compile-image /opt/build/$JARFILE $JARFILE

CMD java -jar $JARFILE
