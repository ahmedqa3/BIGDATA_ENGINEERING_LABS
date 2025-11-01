-- Queries.hql
-- Contient les requêtes analytiques demandées

USE hotel_booking;

-- 1) Lister tous les clients
SELECT * FROM clients;

-- 2) Lister tous les hôtels à Paris
SELECT * FROM hotels WHERE ville = 'Paris' ;

-- 3) Lister toutes les réservations avec les informations sur les hôtels et les clients
SELECT r.reservation_id,
       c.client_id,
       c.nom AS client_nom,
       h.hotel_id,
       h.nom AS hotel_nom,
       r.date_debut,
       r.date_fin,
       r.prix_total
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
JOIN hotels h ON r.hotel_id = h.hotel_id;

-- 6) Requêtes avec jointures
-- Nombre de réservations par client
SELECT c.client_id, c.nom, COUNT(*) AS nb_reservations
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY c.client_id, c.nom
ORDER BY nb_reservations DESC;

-- Clients qui ont réservé plus que 2 nuitées (somme des durées)
SELECT r.client_id, c.nom,
       SUM(datediff(CAST(r.date_fin AS DATE), CAST(r.date_debut AS DATE))) AS total_nuits
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
GROUP BY r.client_id, c.nom
HAVING total_nuits > 2;

-- Hôtels réservés par chaque client (liste)
SELECT r.client_id, c.nom AS client_nom, concat_ws(',', collect_set(h.nom)) AS hotels_reserves
FROM reservations r
JOIN clients c ON r.client_id = c.client_id
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY r.client_id, c.nom;

-- Noms des hôtels avec plus d'une réservation
SELECT h.nom, COUNT(*) AS cnt
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.nom
HAVING cnt > 1;

-- Noms des hôtels sans réservation
SELECT h.nom
FROM hotels h
LEFT JOIN reservations r ON h.hotel_id = r.hotel_id
WHERE r.reservation_id IS NULL;

-- 7) Requêtes imbriquées
-- Clients ayant réservé un hôtel > 4 étoiles
SELECT DISTINCT c.client_id, c.nom
FROM clients c
WHERE c.client_id IN (
  SELECT r.client_id
  FROM reservations r
  JOIN hotels h ON r.hotel_id = h.hotel_id
  WHERE h.etoiles > 4
);

-- Total des revenus générés par chaque hôtel
SELECT h.hotel_id, h.nom, SUM(r.prix_total) AS revenu_total
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.hotel_id, h.nom
ORDER BY revenu_total DESC;

-- 8) Agrégations avec partitions / buckets
-- Revenus totaux par ville
SELECT h.ville, SUM(r.prix_total) AS revenu_par_ville
FROM reservations r
JOIN hotels h ON r.hotel_id = h.hotel_id
GROUP BY h.ville
ORDER BY revenu_par_ville DESC;

-- Nombre total de réservations par client (table bucketed)
SELECT client_id, COUNT(*) AS nb_reservations
FROM reservations_bucketed
GROUP BY client_id
ORDER BY nb_reservations DESC;

-- 9) Nettoyage (décommenter si tu veux supprimer tout)
-- DROP TABLE IF EXISTS reservations_bucketed;
-- DROP TABLE IF EXISTS reservations;
-- DROP TABLE IF EXISTS raw_reservations;
-- DROP TABLE IF EXISTS hotels_partitioned;
-- DROP TABLE IF EXISTS hotels;
-- DROP TABLE IF EXISTS clients;
-- DROP DATABASE IF EXISTS hotel_booking CASCADE;

-- Fin Queries.hql
