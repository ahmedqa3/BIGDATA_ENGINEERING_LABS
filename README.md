# BIGDATA_ENGINEERING_LABS

Ce dépôt contient les travaux pratiques de Big Data Engineering (année 2025-2026). Ci‑dessous un bref résumé des trois labs présents dans le projet.

## Vue d'ensemble

- `lab0/` : mise en place de l'infrastructure Docker pour le cluster (un master et deux slaves). J'ai préparé un `docker-compose.yml` pour démarrer les nœuds et tester les montages de volumes partagés.

- `hadoop_lab/` : labs 1 et 2 — travail avec Hadoop/HDFS et MapReduce. Le code Java et les exemples MapReduce sont placés sous ce dossier (src, pom.xml, exemples de jobs et utilitaires HDFS).


- `lab3_kafka/` : lab 3 — configuration et expérimentations Kafka. Contient :
  - un module `kafka_lab` avec producteurs et consommateurs Java, une app Kafka Streams (WordCount), et des scripts/compose pour Kafka-UI;
  - des instructions pour builder les JARs, les copier dans le volume partagé du conteneur `hadoop-master` et exécuter les tests (producer → topic → consumer);
  - exemples de connect (file source / file sink) et la configuration pour lancer Kafka Connect en standalone.

## Ce que j'ai fait (récit court)

J'ai d'abord installé et configuré l'environnement Docker (lab0) pour disposer d'un master capable d'héberger des composants distribués.

Le détails des autres lab est présenté sur les fichiers readme de chacun.


Ahmed QAIS