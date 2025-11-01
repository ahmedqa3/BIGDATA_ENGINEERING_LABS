## Lab 6 — Apache Hive


Pré-requis
- Dossier de données hôte : C:\Users\ahmed\hadoop_project\hive_data
  (doit contenir clients.txt, hotels.txt, reservations.txt)
- Conteneur Hive lancé et montant le dossier hôte sur /shared_volume


# Exécuter les scripts (ordre)
# 1) création des tables
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Creation.hql"

# 2) chargement des données (copie les fichiers dans C:\Users\ahmed\hadoop_project\hive_data avant)
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Loading.hql"

# 3) exécuter les requêtes analytiques
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Queries.hql"

Le fichier PDF dans ce dossier présente les résultats en screens.

Notes
- Les scripts utilisent des partitions et du bucketing pour montrer des optimisations simples.
- Ne pas oublier d'enlever les en-têtes CSV si présents (ou utiliser preprocessing) avant le LOAD.

Auteur: Ahmed QAIS
