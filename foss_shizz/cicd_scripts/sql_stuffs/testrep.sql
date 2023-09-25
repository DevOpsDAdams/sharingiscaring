mysqldump \
    --host=8.8.8.8 \
    --port=3306 \
    --user=<<some_user>> \
    --password=${sqlpw} \
    --databases <<database1>> \
    --hex-blob \
    --master-data=1 \
    --no-autocommit \
    --default-character-set=utf8mb4 \
    --single-transaction \
    --set-gtid-purged=on \
    --compress \
    | gzip \
    | gsutil cp - gs://gcp-bucket/source-database.sql.gz


/* export sqlpw=$(gcloud secrets versions access latest --secret=prod_sql_root_pw --project my-project)
/* mysql -u master --password=steponmemommy --host=192.191.122.2 --port=3306

UPDATE mysql.user
  SET Host='192.191.122.2' WHERE Host='%' AND User='bitemeharder';
FLUSH PRIVILEGES;
