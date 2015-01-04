#!/bin/bash
set -e

service mysql restart
service mongodb restart

mysql --user=root --password=pseudorandom <<EOF
  DROP DATABASE IF EXISTS controldb;
  CREATE DATABASE controldb;
  GRANT USAGE ON *.* TO 'operator'@'localhost' IDENTIFIED BY 'pseudorandom';
  GRANT ALL PRIVILEGES ON controldb.* to 'operator'@'localhost';
  CREATE TABLE controldb.test(
    id INT NOT NULL AUTO_INCREMENT,
    value CHAR(1) NOT NULL,
    PRIMARY KEY( id )
  );
  INSERT INTO controldb.test(value) VALUES ('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A');
EOF

mongo <<EOF
  use controldb;
  db.dropDatabase();
  db.data.save({pi: 3.14});
  db.addUser({
    user: "operator",
    pwd: "pseudorandom",
    roles: ["read"]
  });
EOF

sudo su postgres <<EOF
  dropdb --if-exists controldb
  dropuser --if-exists operator
  createdb controldb
  createuser operator
EOF

PGPASSWORD=pseudorandom psql -U postgres -h 127.0.0.1 <<EOF
  ALTER USER operator WITH ENCRYPTED PASSWORD 'pseudorandom';
  GRANT CONNECT ON DATABASE controldb TO operator;
  \c controldb
  GRANT USAGE ON SCHEMA public TO operator;
  CREATE TABLE IF NOT EXISTS test (
    id serial PRIMARY KEY,
    value char(1)
  );
  INSERT INTO test(value) VALUES ('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A');
  GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO operator;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO operator;
EOF
