import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableInputFormat;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaDoubleRDD;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class HbaseSparkProcessSum {

    public void run() {

        Configuration config = HBaseConfiguration.create();
        SparkConf sparkConf = new SparkConf()
                .setAppName("SparkHBaseSum")
                .setMaster("local[4]");
        JavaSparkContext jsc = new JavaSparkContext(sparkConf);

        config.set(TableInputFormat.INPUT_TABLE, "products");
        JavaPairRDD<ImmutableBytesWritable, Result> hBaseRDD = jsc.newAPIHadoopRDD(
                config, TableInputFormat.class, ImmutableBytesWritable.class, Result.class);

        long count = hBaseRDD.count();

        JavaRDD<Double> prices = hBaseRDD.values().map(result -> {
            byte[] v = result.getValue(Bytes.toBytes("cf"), Bytes.toBytes("price"));
            if (v == null) return 0.0;
            String s = Bytes.toString(v).trim();
            if (s.isEmpty()) return 0.0;
            try {
                return Double.parseDouble(s);
            } catch (NumberFormatException e) {
                try {
                    return Double.parseDouble(s.replace(',', '.'));
                } catch (NumberFormatException ex) {
                    return 0.0;
                }
            }
        });

        JavaDoubleRDD doublePrices = JavaDoubleRDD.fromRDD(prices.rdd());
        double sum = doublePrices.sum();

        System.out.println("nombre d'enregistrements: " + count);
        System.out.println("somme des prix (cf:price): " + sum);

        jsc.close();
    }

    public static void main(String[] args) {
        HbaseSparkProcessSum app = new HbaseSparkProcessSum();
        app.run();
    }

}
