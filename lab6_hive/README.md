Lab 6 — Apache Hive


Pré-requis
- Dossier de données hôte : C:\Users\ahmed\hadoop_project\hive_data
  (doit contenir clients.txt, hotels.txt, reservations.txt)
- Conteneur Hive lancé et montant le dossier hôte sur /shared_volume



# Démarrer HiveServer2 (exemple PowerShell)
# adapte le chemin si besoin
docker pull apache/hive:4.0.0-alpha-2
docker run -v "${env:USERPROFILE}/hadoop_project:/shared_volume" -d -p 10000:10000 -p 10002:10002 -p 9083:9083 --env SERVICE_NAME=hiveserver2 --name hiveserver2-standalone apache/hive:4.0.0-alpha-2

# Exécuter les scripts (ordre)
# 1) création des tables
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Creation.hql"

# 2) chargement des données (copie les fichiers dans C:\Users\ahmed\hadoop_project\hive_data avant)
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Loading.hql"

# 3) exécuter les requêtes analytiques
docker exec -it hiveserver2-standalone bash -c "beeline -u 'jdbc:hive2://localhost:10000' -n scott -p tiger -f /shared_volume/lab6_hive/Queries.hql"

Notes
- Les scripts utilisent des partitions et du bucketing pour montrer des optimisations simples.
- Ne pas oublier d'enlever les en-têtes CSV si présents (ou utiliser preprocessing) avant le LOAD.

Auteur: Ahmed QAIS
