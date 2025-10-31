# Big Data Engineering Labs

## le fichier "tp1bigdata_HDFS_MapReduce_QAIS_Ahmed_CR.pdf" contient plus de details sur le TP.


Ce dépôt contient les tp 1 et 2 de Big Data Engineering utilisant Hadoop, MapReduce et les technologies Big Data.

## Structure du projet

- `hadoop_lab/` - Projets Java Hadoop
  - `src/main/java/edu/ensias/hadoop/hdfslab/` - Classes pour les opérations HDFS
  - `src/main/java/edu/ensias/hadoop/mapreducelab/` - Classes MapReduce
- `mapper.py` - Script Python pour la phase Map (Hadoop Streaming)
- `reducer.py` - Script Python pour la phase Reduce (Hadoop Streaming)
- `alice.txt` - Fichier de test pour WordCount

## Labs réalisés

### Lab 1 : HDFS Operations
- **HadoopFileStatus** : Affiche les informations d'un fichier HDFS
- **ReadHDFS** : Lit le contenu d'un fichier HDFS
- **WriteHDFS** : Crée un nouveau fichier sur HDFS

### Lab 2 : MapReduce Java
- **WordCount** : Implémentation MapReduce en Java pour compter les occurrences de mots

### Lab 3 : MapReduce Python (Hadoop Streaming)
- **mapper.py** : Script de mapping en Python
- **reducer.py** : Script de réduction en Python

## Technologies utilisées

- Apache Hadoop 3.2.0
- Java 8
- Python 3
- Maven
- Docker (pour l'environnement Hadoop)

## Utilisation

### Compilation des projets Java
```bash
mvn clean package
```

### Exécution des jobs Hadoop
```bash
# WordCount Java
hadoop jar WordCount.jar /user/root/input/file.txt /user/root/output/wordcount

# WordCount Python (Hadoop Streaming)
hadoop jar hadoop-streaming-3.2.0.jar \
    -files mapper.py,reducer.py \
    -mapper "python3 mapper.py" \
    -reducer "python3 reducer.py" \
    -input /user/root/input/file.txt \
    -output /user/root/output/wordcount_python
```


Ahmed QAIS
