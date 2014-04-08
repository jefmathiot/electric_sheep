#!/bin/bash

service mysql restart
service mongodb restart

mysql --user=root --password=pseudorandom <<EOF
  DROP DATABASE IF EXISTS controldb;
  CREATE DATABASE controldb;
  GRANT USAGE ON *.* TO 'operator'@'localhost' IDENTIFIED BY 'pseudorandom';
  GRANT ALL PRIVILEGES ON controldb.* to 'operator'@'localhost';
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
