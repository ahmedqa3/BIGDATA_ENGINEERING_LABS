import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableInputFormat;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.*;
public class HbaseSparkProcess {
public void createHbaseTable() {

    Configuration config = HBaseConfiguration.create();
    SparkConf sparkConf = new SparkConf()
    .setAppName("SparkHBaseTest")
    .setMaster("local[4]");
    JavaSparkContext jsc = new JavaSparkContext(sparkConf);
config.set(TableInputFormat.INPUT_TABLE,"products");
JavaPairRDD<ImmutableBytesWritable, Result> hBaseRDD =jsc.newAPIHadoopRDD(
config, TableInputFormat.class, ImmutableBytesWritable.class, Result.class);
System.out.println("nombre d'enregistrements: "+hBaseRDD.count());
}
public static void main(String[] args){
HbaseSparkProcess admin = new HbaseSparkProcess();
admin.createHbaseTable();
}}