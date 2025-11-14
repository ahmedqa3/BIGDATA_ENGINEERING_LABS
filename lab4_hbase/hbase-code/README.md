TP HBase — hbase-code (Lab 4)

Ahmed QAIS — TP4 HBase

Ce répertoire contient les sources et scripts pour le TP HBase / Spark : exemples Java, import de données via ImportTsv, et jobs Spark lisant la table `products`.

Objectifs
- Charger les données de `purchases2.txt` dans HDFS puis dans une table HBase `products`.
- Explorer HBase (shell, filtres) et exécuter un job Spark qui lit `products` et calcule des métriques (count, somme des prix).

Contenu du répertoire
- `HelloHBase.java` : exemple Java standalone qui crée une table, insère et lit des enregistrements.
- `HbaseSparkProcess.java` : exemple Spark (version simple) qui compte les enregistrements.
- `HbaseSparkProcessSum.java` : (nouveau) job Spark qui lit `cf:price` et calcule la somme des prix.

Prérequis
- Docker Desktop (avec WSL2 si sous Windows) + `docker-compose` pour lancer le cluster (hadoop-master, hadoop-slave1, hadoop-slave2).
- Le conteneur `hadoop-master` contient HDFS, YARN, HBase, ZooKeeper et Spark.
- `purchases2.txt` doit se trouver dans le dossier partagé monté dans le conteneur (`/shared_volume`).

---

Flux de travail A→Z (commandes à lancer dans le conteneur `hadoop-master`)

1) Préparer HDFS (copier le fichier)

```bash
hadoop fs -mkdir -p /user/root/input
hadoop fs -put /shared_volume/purchases2.txt /user/root/input/
```

2) Créer la table HBase `products`

```bash
echo "create 'products','cf'" | hbase shell -n
```

3) Importer les données dans HBase (ImportTsv)

```bash
hbase org.apache.hadoop.hbase.mapreduce.ImportTsv \
  -Dimporttsv.separator=',' \
  -Dimporttsv.columns=HBASE_ROW_KEY,cf:date,cf:time,cf:town,cf:product,cf:price,cf:payment \
  products /user/root/input/purchases2.txt
```

Notes :
- Si ImportTsv échoue pour une classe manquante (ex. `ArrayUtils`), ajoutez le jar manquant via `-libjars` ou placez le jar dans le classpath du conteneur.

4) Compiler et créer le jar Spark

```bash
cd /root/lab4_hbase/hbase-code
mkdir -p out
javac -cp "/usr/local/hbase/lib/*:/usr/local/spark/jars/*" -d out HbaseSparkProcessSum.java
jar cvf processing-hbase-sum.jar -C out .
jar tf processing-hbase-sum.jar | sed -n '1,200p'
```

5) Exécuter le job Spark

Local (driver dans le conteneur) :

```bash
spark-submit --master local[4] --class HbaseSparkProcessSum processing-hbase-sum.jar --files /usr/local/hbase/conf/hbase-site.xml
```

Sur YARN (client mode) :

```bash
spark-submit --master yarn --deploy-mode client --class HbaseSparkProcessSum \
  --files /usr/local/hbase/conf/hbase-site.xml \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=file:///tmp/spark-logs \
  processing-hbase-sum.jar
```

6) Vérifier les résultats

- Compter directement depuis HBase :

```bash
echo "count 'products'" | hbase shell -n
```

- Vérifier la somme affichée par le job Spark dans la sortie `spark-submit` ou via les event logs (`/tmp/spark-logs`).

7) Mettre à jour une cellule HBase (ex. row '8' cf:town)

```bash
echo "put 'products','8','cf:town','New york'" | hbase shell -n
echo "get 'products','8'" | hbase shell -n
```

---

Dépannage et bonnes pratiques
- Docker/WSL : si `docker exec` renvoie une erreur 500, redémarrer Docker Desktop / vérifier WSL2.
- Classes manquantes : pour ImportTsv ou Spark, ajouter les jars manquants via `-libjars`, `--jars` ou `--files`.
- Packaging : assurez-vous que le package Java correspond au `--class` passé à `spark-submit`.
- Spark UI : voir `http://<driver-host>:4040` pendant l'exécution ; pour UIs persistantes, démarrer le Spark History Server et configurer `spark.eventLog.dir`.
- HBase hbck : faites un backup avant d'exécuter `hbase hbck -fixMeta` ou `-fixAssignments`.

Fichiers clés
- `HbaseSparkProcessSum.java` — job Spark pour somme des `cf:price`.
- `processing-hbase-sum.jar` — jar produit par `jar cvf`.
- HBase logs : `/usr/local/hbase/logs`.
- Event logs Spark : `/tmp/spark-logs` (si configuré).

Activités avancées (optionnelles)
- Somme `price * quantity` : adapter le mapping pour lire `cf:quantity` et multiplier.
- Repackager les classes dans `package bigdata.hbase.tp` pour utiliser `--class bigdata.hbase.tp.YourClass`.
- Démarrer Spark History Server : `/usr/local/spark/sbin/start-history-server.sh`.

---

Si tu veux, je peux générer un script `build-and-run.sh` qui compile, crée le jar et lance `spark-submit` automatiquement, ou repackager les sources en ajoutant un package Java.

Ahmed QAIS
