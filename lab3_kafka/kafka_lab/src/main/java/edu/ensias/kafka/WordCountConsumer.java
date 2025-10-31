package edu.ensias.kafka;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class WordCountConsumer {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("Usage: WordCountConsumer <topic> [bootstrap.servers] [groupId]");
            System.exit(1);
        }
        String topic = args[0];
        String bootstrap = args.length > 1 ? args[1] : "localhost:9092";
        String groupId = args.length > 2 ? args[2] : "wordcount-group";

        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");

        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Collections.singletonList(topic));

        Map<String, Long> counts = new HashMap<>();
        System.out.println("WordCountConsumer started. Subscribed to topic: " + topic);
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));
            for (ConsumerRecord<String, String> r : records) {
                String word = r.key() != null ? r.key() : r.value();
                if (word == null) continue;
                word = word.toLowerCase();
                counts.put(word, counts.getOrDefault(word, 0L) + 1);
                System.out.printf("word=%s count=%d partition=%d offset=%d%n", word, counts.get(word), r.partition(), r.offset());
            }
        }
    }
}
