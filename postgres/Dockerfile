FROM alpine
RUN apk add --no-cache postgresql-client
COPY init.sql /docker-entrypoint-initdb.d/init.sql
ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
CMD ["sh", "-c", "export PGPASSWORD=$POSTGRES_PASSWORD && until pg_isready -h db -U $POSTGRES_USER; do echo waiting for database; sleep 2; done; psql -h db -U $POSTGRES_USER -d $POSTGRES_DB -a -f /docker-entrypoint-initdb.d/init.sql"]