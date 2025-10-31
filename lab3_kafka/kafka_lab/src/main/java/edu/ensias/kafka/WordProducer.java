package edu.ensias.kafka;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Properties;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

public class WordProducer {
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: WordProducer <topic> [bootstrap.servers]");
            System.exit(1);
        }
        String topic = args[0];
        String bootstrap = args.length > 1 ? args[1] : "localhost:9092";

        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.ACKS_CONFIG, "all");

        Producer<String, String> producer = new KafkaProducer<>(props);
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        System.out.println("WordProducer started. Type text; each word will be sent to topic='" + topic + "'");
        String line;
        while ((line = br.readLine()) != null) {
            line = line.trim();
            if (line.isEmpty()) continue;
            String[] words = line.split("\\s+");
            for (String w : words) {
                if (w == null || w.isEmpty()) continue;
                String word = w.toLowerCase();
                ProducerRecord<String, String> rec = new ProducerRecord<>(topic, word, "1");
                producer.send(rec, (meta, ex) -> {
                    if (ex != null) ex.printStackTrace();
                });
            }
        }
        producer.flush();
        producer.close();
    }
}
