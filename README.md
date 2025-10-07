# BIG DATA ENGINEERING – Lab 1  
**Année universitaire : 2025-2026**  
**Étudiant : Ahmed QAIS**

> Ce dépôt contient la réalisation du **Lab 1 : Programmation avec l’API HDFS et MapReduce**, dans le cadre du cours de **Big Data Engineering**.

---

## 🎯 Objectifs du TP

- ✅ Manipuler les fichiers sur **HDFS** via l’**API Java Hadoop** :
  - Lire les métadonnées d’un fichier (`HadoopFileStatus`)
  - Lire le contenu d’un fichier (`ReadHDFS`)
  - Écrire un nouveau fichier (`WriteHDFS`)
- ✅ Implémenter le classique **WordCount** en **Java (MapReduce)**.
- ✅ Réaliser le même traitement en **Python** avec **Hadoop Streaming**.
- ✅ Versionner le code avec **Git/GitHub**.

---

## Structure du projet

- `hadoop_lab/` - Projets Java Hadoop
  - `src/main/java/edu/ensias/hadoop/hdfslab/` - Classes pour les opérations HDFS
  - `src/main/java/edu/ensias/hadoop/mapreducelab/` - Classes MapReduce
- `mapper.py` - Script Python pour la phase Map (Hadoop Streaming)
- `reducer.py` - Script Python pour la phase Reduce (Hadoop Streaming)
- `alice.txt` - Fichier de test pour WordCount


## Technologies utilisées

- Apache Hadoop 3.2.0
- Java 8
- Python 3
- Maven
- Docker (pour l'environnement Hadoop avec cluster Hadoop : `hadoop-master`, `hadoop-slave1`, `hadoop-slave2`)

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

## Auteur

Ahmed QAIS
