-- Loading.hql
-- Charge les fichiers plats depuis /shared_volume/hive_data et peuple les tables

USE hotel_booking;

-- Rappel des paramètres utiles
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.enforce.bucketing=true;

-- Remplacer les chemins si besoin. Les fichiers doivent être accessibles dans le conteneur
-- via le volume monté sous /shared_volume/hive_data

-- Charger clients et hotels (fichiers plats)
LOAD DATA LOCAL INPATH '/shared_volume/hive_data/clients.txt' INTO TABLE clients;
LOAD DATA LOCAL INPATH '/shared_volume/hive_data/hotels.txt' INTO TABLE hotels;

-- Charger les réservations dans la table de staging
LOAD DATA LOCAL INPATH '/shared_volume/hive_data/reservations.txt' INTO TABLE raw_reservations;

-- Insérer dynamiquement dans la table partitionnée 'reservations'
INSERT INTO TABLE reservations PARTITION (date_debut)
SELECT
  reservation_id,
  client_id,
  hotel_id,
  CAST(date_fin AS DATE) AS date_fin,
  CAST(prix_total AS DECIMAL(10,2)) AS prix_total,
  date_debut
FROM raw_reservations;

-- Remplir hotels_partitioned par ville (dynamic partition)
INSERT INTO TABLE hotels_partitioned PARTITION (ville)
SELECT hotel_id, nom, etoiles, ville FROM hotels;

-- Remplir reservations_bucketed (enforcement nécessaire)
SET hive.enforce.bucketing=true;

-- INSERT OVERWRITE est recommandé pour que Hive écrive les fichiers de buckets correctement
INSERT OVERWRITE TABLE reservations_bucketed
SELECT reservation_id, client_id, hotel_id, date_debut, date_fin, prix_total
FROM raw_reservations
DISTRIBUTE BY client_id;

-- Vérifications rapides
SHOW PARTITIONS reservations;
SELECT COUNT(*) AS cnt_reservations FROM reservations;
SELECT COUNT(*) AS cnt_clients FROM clients;
SELECT COUNT(*) AS cnt_hotels FROM hotels;

-- Fin Loading.hql
