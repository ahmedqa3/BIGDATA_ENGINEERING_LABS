# Lab 3 — Kafka

Ahmed QAIS - 3A BI&A

## le fichier "CR_QAISAhmed_TP3_Kafka.pdf" contient plus de details sur le TP.

Ce répertoire contient les sources et les scripts pour le lab Kafka (Lab 3). 

Contenu principal
- `kafka_lab/src/main/java/edu/ensias/kafka/` : classes Java
  - `EventProducer`, `EventConsumer` : exemples de producteur/consommateur
  - `WordProducer` : lit le clavier et envoie chaque mot sur un topic
  - `WordCountConsumer` : consomme un topic et affiche un compteur par mot (en mémoire)
  - `WordCountApp` : application Kafka Streams (word count)
- `pom.xml` : build Maven (génère un `*-jar-with-dependencies.jar` dans `target/`)
- `docker-compose.yml` : compose pour lancer Kafka‑UI (optionnel)

Étapes rapides
1. Build (sur la machine hôte)

```powershell
cd lab3_kafka/kafka_lab
mvn clean package
```

2. Copier le fat-jar vers le dossier partagé monté dans le conteneur (visible comme `/shared_volume/kafka`)

```powershell
Copy-Item -Path .\target\*jar-with-dependencies*.jar -Destination "C:\Users\ahmed\Downloads\hadoop_project\kafka" -Force
```

3. Créer les topics (dans le conteneur `hadoop-master`)

```bash
# depuis le conteneur
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic input-topic --partitions 1 --replication-factor 1
/usr/local/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic output-topic --partitions 1 --replication-factor 1
```

4. Lancer les applis dans le conteneur

Producer (interactive) :
```bash
java -cp /shared_volume/kafka/*jar-with-dependencies*.jar edu.ensias.kafka.WordProducer input-topic localhost:9092
```

Consumer (affiche les comptes) :
```bash
java -cp /shared_volume/kafka/*jar-with-dependencies*.jar edu.ensias.kafka.WordCountConsumer output-topic localhost:9092
```

5. Tester via console

```bash
# produire sur input-topic
/usr/local/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic input-topic

# consommer output-topic
/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic output-topic --from-beginning --property print.key=true
```

Note — multi-brokers
- Le conteneur `hadoop-master` contient une installation Kafka (habituellement `/usr/local/kafka`).
- Pour un cluster multi-brokers, ajouter des fichiers `server-one.properties` / `server-two.properties` (ports 9093/9094), démarrer plusieurs brokers et créer un topic avec `--replication-factor 2`.

Kafka-UI
- `docker-compose.yml` fournit un service `kafka-ui` (port hôte 8081) que vous pouvez lancer pour inspecter le cluster.

Remarques
- Le consommateur `WordCountConsumer` garde les compteurs en mémoire — ce n'est pas persistant.
- Si vous préférez des jars dédiés (producer / consumer), on peut ajouter des exécutions `maven-shade-plugin` au `pom.xml` pour générer des jars avec `Main-Class`.

---

Ahmed QAIS
