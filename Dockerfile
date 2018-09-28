FROM postgres:10

LABEL vendor="Overseas Labs Limited" \
      vendor.website=http://overseaslsbs.com \
      description="The postgres database" \
      project="Example Project" \
      tag="overseaslabs/example-postgres:1.0.0"

#the script creating users and databases
COPY init.sh /docker-entrypoint-initdb.d/