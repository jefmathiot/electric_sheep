#!/bin/bash

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
