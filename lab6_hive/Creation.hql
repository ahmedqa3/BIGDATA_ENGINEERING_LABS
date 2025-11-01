-- Creation.hql
-- Crée la base hotel_booking et toutes les tables nécessaires (partitions / buckets activés)

CREATE DATABASE IF NOT EXISTS hotel_booking;
USE hotel_booking;

-- Paramètres pour partitions dynamiques et bucketing
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions=20000;
SET hive.exec.max.dynamic.partitions.pernode=20000;
SET hive.enforce.bucketing=true;

-- Table clients
CREATE TABLE IF NOT EXISTS clients (
  client_id INT,
  nom STRING,
  email STRING,
  telephone STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table hotels (source non-partitionnée)
CREATE TABLE IF NOT EXISTS hotels (
  hotel_id INT,
  nom STRING,
  etoiles INT,
  ville STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table de staging pour les réservations (contient la colonne date_debut pour partitionnement)
CREATE TABLE IF NOT EXISTS raw_reservations (
  reservation_id INT,
  client_id INT,
  hotel_id INT,
  date_debut STRING,
  date_fin STRING,
  prix_total DECIMAL(10,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table reservations partitionnée par date_debut (format de partition attendu: 'YYYY-MM-DD')
CREATE TABLE IF NOT EXISTS reservations (
  reservation_id INT,
  client_id INT,
  hotel_id INT,
  date_fin DATE,
  prix_total DECIMAL(10,2)
)
PARTITIONED BY (date_debut STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table hotels partitionnée par ville (exemple de partition)
CREATE TABLE IF NOT EXISTS hotels_partitioned (
  hotel_id INT,
  nom STRING,
  etoiles INT
)
PARTITIONED BY (ville STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Table reservations bucketed par client_id (4 buckets)
CREATE TABLE IF NOT EXISTS reservations_bucketed (
  reservation_id INT,
  client_id INT,
  hotel_id INT,
  date_debut STRING,
  date_fin STRING,
  prix_total DECIMAL(10,2)
)
CLUSTERED BY (client_id) INTO 4 BUCKETS
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Fin Creation.hql
