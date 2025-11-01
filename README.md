# BIGDATA_ENGINEERING_LABS

**Année universitaire : 2025-2026**  
Ce dépôt contient les travaux pratiques du cours Big Data Engineering. Voici un résumé organisé des labos et éléments présents dans le projet.
=======
<<<<<<< HEAD
# BIG DATA ENGINEERING – Lab 1  
1. Infrastructure Docker (lab0)
**Étudiant : Ahmed QAIS**

2. Hadoop / MapReduce (lab1 & lab2)
# BIG DATA ENGINEERING LABS

**Année universitaire : 2025-2026**

**Étudiant : Ahmed QAIS**

Ce dépôt contient les travaux pratiques du cours Big Data Engineering. Voici un résumé organisé des labos et éléments présents dans le projet.

## Vue d'ensemble

- `lab0/` : infrastructure Docker pour un petit cluster (master + slaves) avec `docker-compose.yml` pour démarrer les nœuds et tester les montages de volumes partagés.
- `hadoop_lab/` : labs 1 & 2 — travaux sur Hadoop/HDFS et MapReduce. Contient les sources Java, les exemples MapReduce et des scripts pour exécution dans l'environnement Hadoop.
- `lab3_kafka/` : lab 3 — expérimentations Kafka. Contient le module `kafka_lab` avec producteurs/consommateurs Java, une app Kafka Streams (WordCount), des exemples Kafka Connect, et un `docker-compose.kafka-ui.yml` pour Kafka‑UI.
- `lab6_hive/` : lab 6 — scripts HiveQL pour création, chargement et requêtes analytiques (tests réalisés dans un conteneur `hiveserver2-standalone` avec volume partagé `/shared_volume`).

## Ce que j'ai implémenté

1. Infrastructure Docker (lab0)
  - `docker-compose.yml` pour démarrer `hadoop-master` et deux slaves. Le master expose un volume partagé pour déposer des JARs et fichiers à utiliser par les services du conteneur.

2. Hadoop / MapReduce (lab1 & lab2)
  - Exemples Java : utilitaires HDFS (`HadoopFileStatus`, `ReadHDFS`, `WriteHDFS`) et job WordCount en Java.
  - Exemple Python : mapper/reducer pour Hadoop Streaming.

3. Kafka (lab3)
  - Producteurs/consommateurs Java (`EventProducer`, `EventConsumer`), outils interactifs (`WordProducer`, `WordCountConsumer`).
  - Kafka Streams : `WordCountApp` (exemple stateful avec store local).
  - Kafka Connect examples (file source -> topic -> file sink) et compose pour Kafka‑UI.

4. Hive (lab6)
  - Installation et premières manipulations avec Apache Hive (HiveServer2 / Beeline).
  - Scripts HiveQL fournis pour : création des tables, chargement des données et requêtes analytiques (`lab6_hive/Creation.hql`, `lab6_hive/Loading.hql`, `lab6_hive/Queries.hql`).

## Prérequis

- Apache Hadoop 3.x
- Java 8 (JDK)
- Maven
- Docker (pour l'environnement avec `hadoop-master`, Kafka, Hive)

## Commandes utiles

### Compiler les projets Java
```powershell
cd lab3_kafka/kafka_lab
mvn clean package -DskipTests
```

### Exécution des jobs Hadoop (exemples)
```powershell
# WordCount Java (exécution depuis le conteneur master)
hadoop jar hadoop_lab/target/WordCount.jar /user/root/input/file.txt /user/root/output/wordcount

# Hadoop Streaming (Python)
hadoop jar /path/to/hadoop-streaming.jar -files mapper.py,reducer.py -mapper "python3 mapper.py" -reducer "python3 reducer.py" -input /user/root/input -output /user/root/output_python
```

## Notes et bonnes pratiques

- Les artefacts compilés (dossiers `target/`, JARs) ne devraient pas être commités dans le dépôt principal. Il est recommandé d'ajouter `target/` à `.gitignore` et de ne versionner que les sources et la documentation.
- Pour publier les JARs d'exécution, utiliser les Releases GitHub ou un dossier partagé externe plutôt que de committer les binaires dans `master`.

---
Auteur : Ahmed QAIS
