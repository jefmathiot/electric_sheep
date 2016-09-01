#!/bin/bash
set -e

service mysql restart
service mongodb restart

# Using a name with an asterisk and whitespace to ensure ES.IO properly escapes
# special characters.
mysql --user=root --password=pseudorandom <<EOF
  SET sql_mode='ANSI_QUOTES';
  DROP DATABASE IF EXISTS "control *db";
  CREATE DATABASE "control *db";
  GRANT USAGE ON *.* TO 'operator'@'localhost' IDENTIFIED BY 'pseudorandom';
  GRANT ALL PRIVILEGES ON "control *db".* to 'operator'@'localhost';
  CREATE TABLE "control *db".table1(
    id INT NOT NULL AUTO_INCREMENT,
    value CHAR(1) NOT NULL,
    PRIMARY KEY( id )
  );
  CREATE TABLE "control *db".table2(
    id INT NOT NULL AUTO_INCREMENT,
    value CHAR(1) NOT NULL,
    PRIMARY KEY( id )
  );
  INSERT INTO "control *db".table1(value) VALUES ('A'),('A'),('A'),('A'),('A'),
    ('A'),('A'),('A'),('A'),('A');
  INSERT INTO "control *db".table2(value) VALUES ('A'),('A'),('A'),('A'),('A'),
    ('A'),('A'),('A'),('A'),('A');
EOF

# Unlike MySQL, MongoDB does not allow whitespace characters in database
# names.
mongo <<EOF
  use control\*db;
  db.dropDatabase();
  db.data.save({pi: 3.14});
  db.addUser({
    user: "operator",
    pwd: "pseudorandom",
    roles: ["read"]
  });
EOF

# Unlike MySQL, PostgreSQL does not allow whitespace characters in database
# names.
sudo su postgres <<EOF
  dropdb --if-exists "control*db"
  dropuser --if-exists operator
  createdb "control*db"
  createuser operator
EOF

PGPASSWORD=pseudorandom psql -U postgres -h 127.0.0.1 <<EOF
  ALTER USER operator WITH ENCRYPTED PASSWORD 'pseudorandom';
  GRANT CONNECT ON DATABASE "control*db" TO operator;
  \c "control*db"
  GRANT USAGE ON SCHEMA public TO operator;
  CREATE TABLE IF NOT EXISTS test (
    id serial PRIMARY KEY,
    value char(1)
  );
  INSERT INTO test(value) VALUES ('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A'),('A');
  GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO operator;
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO operator;
EOF
