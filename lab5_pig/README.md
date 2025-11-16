# TP 5 — Guide complet et Résultats (Pig / Vols / Films)

Ce document rassemble les instructions pratiques, les commandes « copy‑paste » à coller dans le conteneur `hadoop-master`, des exemples de scripts Pig et des conseils de dépannage. Il explique aussi où retrouver les résultats produits et propose des alternatives (AWK / Python) si le mode MapReduce pose problème.

Important : ce fichier est une documentation — il ne lance rien automatiquement. Collez les commandes dans le shell du conteneur Docker quand vous êtes prêt.

---

## 1. Résumé des objectifs

- Préparer les fichiers (airports, carriers, flights, movies, users) dans HDFS.
- Exécuter des analyses Pig sur :
  - Top 20 aéroports (entrants, sortants, totaux), par périodes (jour, mois, année)
  - Popularité des transporteurs (volume par année, classement)
  - Proportion de vols retardés (>15 min) par granularités temporelles
  - Retards par transporteur
  - Itinéraires (routes) les plus fréquentés (paire non ordonnée)
- Analyses sur les fichiers films / users (films par année, par genre, stats de notation, top50)

---

## 2. Pré‑requis

- Un conteneur `hadoop-master` en cours d'exécution (HDFS + YARN idéalement).
- Les fichiers sources copiés dans le volume partagé du conteneur (exemple : `/shared_volume`).
- Accès shell au conteneur :

```bash
docker exec -it hadoop-master bash
```

---

## 3. Installation et configuration d'Apache Pig (dans le conteneur)

1. Télécharger et installer Pig (exemple 0.17.0) :

```bash
wget https://dlcdn.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz
tar -zxvf pig-0.17.0.tar.gz
mv pig-0.17.0 /usr/local/pig
rm pig-0.17.0.tar.gz

# ajouter au ~/.bashrc
echo "export PIG_HOME=/usr/local/pig" >> ~/.bashrc
echo "export PATH=\$PATH:\$PIG_HOME/bin" >> ~/.bashrc
source ~/.bashrc
```

2. (Optionnel mais recommandé) activer WebHDFS et Timeline / History server :

- Modifier `$HADOOP_CONF_DIR/hdfs-site.xml` pour activer `dfs.webhdfs.enabled=true`.
- Modifier `$HADOOP_CONF_DIR/yarn-site.xml` pour activer `yarn.timeline-service.enabled=true` et fixer `yarn.timeline-service.hostname`.

3. Démarrer les services si nécessaire (varie selon votre image Docker) :

```bash
# si votre image a un script de démarrage
./start-hadoop
# lancer timeline & historyserver
yarn timelineserver &
mapred --daemon start historyserver
```

---

## 4. Copier les fichiers du volume partagé vers HDFS

Vous avez indiqué que vos fichiers sont dans `/shared_volume` (exemple : `airports.csv`, `carriers.csv`, `test.csv`, ...). Pour les mettre sur HDFS :

Collez dans le conteneur :

```bash
# créer dossier HDFS
hdfs dfs -mkdir -p /user/root/input/shared_volume

# uploader tous les CSV du volume partagé
hdfs dfs -put -f /shared_volume/*.csv /user/root/input/shared_volume/

# vérifier
hdfs dfs -ls -h /user/root/input/shared_volume

# vérifier un extrait
hdfs dfs -cat /user/root/input/shared_volume/airports.csv | sed -n '1,10p'
```

Remarque : remplacez `*.csv` par la liste des fichiers précis si vous ne voulez pas tout copier.

---

## 5. Scripts Pig — exemples prêts à l'emploi

Ci‑dessous les extraits Pig à coller dans un fichier `.pig` (ex : `/tmp/flights_analysis.pig`). Ils supposent que les fichiers sont sur HDFS sous `/user/root/input/shared_volume/`.

### 5.1 Chargement des données de vols (exemple schema adapté)

```pig
Flights = LOAD '/user/root/input/shared_volume/test.csv' USING PigStorage(',') AS (
    Year:int, Month:int, DayofMonth:int, DayOfWeek:int,
    DepTime:chararray, CRSDepTime:chararray, ArrTime:chararray, CRSArrTime:chararray,
    UniqueCarrier:chararray, FlightNum:int, TailNum:chararray,
    ActualElapsedTime:int, CRSElapsedTime:int, AirTime:int,
    ArrDelay:int, DepDelay:int, Origin:chararray, Dest:chararray,
    Distance:int, TaxiIn:int, TaxiOut:int,
    Cancelled:int, CancellationCode:chararray, Diverted:int,
    CarrierDelay:int, WeatherDelay:int, NASDelay:int, SecurityDelay:int, LateAircraftDelay:int
);

ValidFlights = FILTER Flights BY (Cancelled == 0 AND Diverted == 0);
```

### 5.2 Top 20 aéroports (entrants + sortants)

```pig
Departures = FOREACH ValidFlights GENERATE Origin AS Airport;
Arrivals = FOREACH ValidFlights GENERATE Dest AS Airport;
AllFlights = UNION Departures, Arrivals;

VolumeByAirport = GROUP AllFlights BY Airport;
TotalVolume = FOREACH VolumeByAirport GENERATE group AS Airport, COUNT(AllFlights) AS TotalFlights;

SortedVolume = ORDER TotalVolume BY TotalFlights DESC;
Top20Airports = LIMIT SortedVolume 20;
STORE Top20Airports INTO '/user/root/output/flight_analysis/top20_airports' USING PigStorage('\t');
```

### 5.3 Itinéraires les plus fréquentés (paire non ordonnée)

```pig
AirportPairs = FOREACH ValidFlights GENERATE Origin, Dest;
NormalizedPairs = FOREACH AirportPairs GENERATE (Origin < Dest ? Origin : Dest) AS A1, (Origin < Dest ? Dest : Origin) AS A2;
ItinerairesGroup = GROUP NormalizedPairs BY (A1, A2);
Frequences = FOREACH ItinerairesGroup GENERATE group.A1 AS Origin, group.A2 AS Dest, COUNT(NormalizedPairs) AS Frequency;
TopItineraires = ORDER Frequences BY Frequency DESC;
STORE TopItineraires INTO '/user/root/output/flight_analysis/top_routes' USING PigStorage('\t');
```

### 5.4 Proportion de vols retardés (>15 min) par granularité

```pig
DelayedFlights = FOREACH ValidFlights GENERATE (ArrDelay > 15 ? 1 : 0) AS Delayed, Year, Month, DayofMonth, DayOfWeek, (int)( (DepTime is null ? 0 : (int)DepTime) / 100 ) AS Hour;

DelayByHour = FOREACH (GROUP DelayedFlights BY Hour) GENERATE group AS Hour, AVG(DelayedFlights.Delayed) AS DelayProportion;
STORE DelayByHour INTO '/user/root/output/flight_analysis/delay_by_hour' USING PigStorage('\t');
```

### 5.5 Popularité des transporteurs (volume par année + log10)

```pig
CarrierYear = GROUP ValidFlights BY (UniqueCarrier, Year);
CarrierVolume = FOREACH CarrierYear GENERATE group.UniqueCarrier AS Carrier, group.Year AS Year, COUNT(ValidFlights) AS TotalFlights;
CarrierLog = FOREACH CarrierVolume GENERATE Carrier, Year, LOG10((double)TotalFlights + 1) AS LogVolume;
STORE CarrierLog INTO '/user/root/output/flight_analysis/carrier_log_volume' USING PigStorage('\t');
```

---

## 6. Commandes complètes — copy/paste dans le conteneur

Bloc recommandé pour copier les fichiers, écrire un script Pig et le lancer (MapReduce) :

```bash
# 1) copier CSV vers HDFS
hdfs dfs -mkdir -p /user/root/input/shared_volume
hdfs dfs -put -f /shared_volume/*.csv /user/root/input/shared_volume/

# 2) écrire le script Pig (ex : /tmp/flights_analysis.pig)
cat > /tmp/flights_analysis.pig <<'PIG'
# (collez ici le contenu Pig des sections 5.1 à 5.5)
PIG

# 3) supprimer d'anciennes sorties qui pourraient bloquer
hdfs dfs -rm -r -f /user/root/output/flight_analysis

# 4) exécuter Pig en mode cluster (MapReduce)
HADOOP_OPTS='-Dyarn.timeline-service.enabled=false' pig -x mapreduce -f /tmp/flights_analysis.pig

# 5) lister et inspecter
hdfs dfs -ls -h /user/root/output/flight_analysis
hdfs dfs -cat /user/root/output/flight_analysis/top20_airports/part-* | head -n 20
```

Si vous préférez exécuter en local (debug rapide) :

```bash
pig -x local -f /tmp/flights_analysis.pig
ls -l /tmp/pig_output
cat /tmp/pig_output/top20_airports/part-* | head -n 20
```

---

## 7. Résultats attendus & emplacement

- Sorties Pig (HDFS) : `/user/root/output/flight_analysis/` contenant :
  - `top20_airports/part-*`
  - `top_routes/part-*`
  - `delay_by_hour/part-*`, `delay_by_day/part-*`, etc.
  - `carrier_log_volume/part-*`

- Sorties Films (local / tmp) :
  - `/tmp/pig_output/movies_per_year/part-*`
  - `/tmp/pig_output/movies_per_genre/part-*`
  - `/tmp/pig_output/movie_rating_stats/part-*`
  - `/tmp/pig_output/top50_movies/part-*`
  - `/user/root/output/mUSA_annee_flat.tsv` (si vous avez utilisé l'étape de flatten HDFS)

Utilisez `hdfs dfs -cat <path>/part-* | head -n 40` pour inspecter les fichiers produits.

---

## 8. Problèmes courants & solutions

- Erreur "Input path does not exist: hdfs://.../tmp/…" : cela arrive si votre script Pig est configuré pour MapReduce mais référence des chemins locaux (`/tmp/...`) — assurez‑vous d'utiliser des chemins HDFS pour MapReduce.
- Erreur "Your endpoint configuration is wrong" (connexion à 0.0.0.0:10020): indique un problème de configuration YARN/JobHistory/Timeline. Contournement : exécuter Pig en mode local (`-x local`) ou utiliser des alternatives AWK/Python pour analyses rapides.
- Problèmes JSON / JsonLoader : Pig 0.17 peut nécessiter `piggybank.jar` pour loader JSON; plus simple : convertir JSON→TSV et traiter avec `PigStorage('\t')`.

---

## 9. Alternatives rapides (si MapReduce impossible)

- AWK (compte par année à partir d'un fichier `movies.tsv`) :

```bash
awk 'NR>1 { if (match($0,/\([0-9]{4}\)/)) { y=substr($0,RSTART+1,4); cnt[y]++ } } END { for (y in cnt) print y "\t" cnt[y] }' /tmp/movies.tsv | sort -k2 -nr > /tmp/movies_per_year.tsv
head -n 40 /tmp/movies_per_year.tsv
```

- Script Python local (plus complet) : j'ai fourni un script `lab5_pig/local_analytics.py` qui calcule movies_per_year, movies_per_genre, movie_rating_stats et top50 sans Spark ni Pig. (Exécuter localement avec `python lab5_pig/local_analytics.py --movies <path> --users <path>`).

---

## 10. Conseils d'exploitation

- Testez d'abord en `pig -x local` pour valider la logique, puis passez en MapReduce (`pig -x mapreduce`) pour des gros volumes.
- Pour les gros jeux (millions de lignes) utilisez Spark (script PySpark fourni sur demande) — plus résilient et performant.
- Versionnez vos scripts Pig dans le repo `lab5_pig/` (ex : `flights_analysis.pig`, `movies_analysis.pig`, `wordcount.pig`).

---

Si vous voulez, je peux maintenant :

- Générer un fichier `/tmp/flights_analysis.pig` complet (je fournis le bloc entier prêt à coller).  
- Générer un script PySpark complet (si vous préférez Spark).  
- Ajouter des exemples concrets de sorties (extraits) si vous me donnez le contenu d'un `part-*` produit.

Indiquez ce que vous souhaitez que je fournisse en priorité (script Pig complet pour les vols, script PySpark, ou uniquement commandes HDFS + vérification).
