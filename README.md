# BIGDATA_ENGINEERING_LABS

Ce dépôt contient les travaux pratiques de Big Data Engineering (année 2025-2026). Ci‑dessous un bref résumé des trois labs présents dans le projet.
=======
# BIG DATA ENGINEERING  
**Année universitaire : 2025-2026**  
**Étudiant : Ahmed QAIS**


## Vue d'ensemble

- `lab0/` : infrastructure Docker pour un petit cluster (master + slaves) avec `docker-compose.yml` pour démarrer les nœuds et tester les montages de volumes partagés.
- 
- `hadoop_lab/` : labs 1 & 2 — travaux sur Hadoop/HDFS et MapReduce. Contient les sources Java, les exemples MapReduce et des scripts pour exécution dans l'environnement Hadoop.
- 
- `lab3_kafka/` : lab 3 — expérimentations Kafka. Contient le module `kafka_lab` avec producteurs/consommateurs Java, une app Kafka Streams (WordCount), des exemples Kafka Connect, et un `docker-compose.kafka-ui.yml` pour Kafka‑UI.

## Ce que j'ai implémenté

1. Infrastructure Docker (lab0)
  - `docker-compose.yml` pour démarrer `hadoop-master` et deux slaves. Le master expose un volume partagé pour déposer des JARs et fichiers à utiliser par les services du conteneur.

2. Hadoop / MapReduce (lab1 & lab2)
  - Exemples Java : utilitaires HDFS (`HadoopFileStatus`, `ReadHDFS`, `WriteHDFS`) et job WordCount en Java.
  - Exemple Python : mapper/reducer pour Hadoop Streaming.

Un résumé se trouve sur les fichiers PDF et README du dossier du Lab

3. Kafka (lab3)
  - Producteurs/consommateurs Java (`EventProducer`, `EventConsumer`), outils interactifs (`WordProducer`, `WordCountConsumer`).
  - Kafka Streams : `WordCountApp` (exemple stateful avec store local).
  - Kafka Connect examples (file source -> topic -> file sink) et compose pour Kafka‑UI.

Un résumé se trouve sur les fichiers PDF et README du dossier du Lab.

---
Auteur : Ahmed QAIS

````
