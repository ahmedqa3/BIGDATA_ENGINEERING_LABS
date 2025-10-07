package edu.ensias.hadoop.hdfslab;


import java.io.IOException;

 import org.apache.hadoop.conf.Configuration;
 import org.apache.hadoop.fs.BlockLocation;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
 public class HadoopFileStatus {
 public static void main(String[] args) {
 // Check if we have enough arguments
 if (args.length != 3) {
     System.out.println("Usage: java HadoopFileStatus <inputDir> <fileName> <newName>");
     System.out.println("Example: java HadoopFileStatus /user/root/input purchases.txt achats.txt");
     System.exit(1);
 }
 
 String inputDir = args[0]; // ex: /user/root/input
 String fileName = args[1]; // ex: purchases.txt
 String newName = args[2];  // ex: achats.txt
 Path filepath = new Path(inputDir, fileName);
 Path newpath = new Path(inputDir, newName);
 
 Configuration conf = new Configuration();
 FileSystem fs;
 try {
 fs = FileSystem.get(conf);
 FileStatus infos = fs.getFileStatus(filepath);
 if(!fs.exists(filepath)){
 System.out.println("File does not exists");
 System.exit(1);
 }
 System.out.println(Long.toString(infos.getLen())+" bytes");
 System.out.println("File Name: "+filepath.getName());
 System.out.println("File Size: "+infos.getLen());
 System.out.println("File owner: "+infos.getOwner());
 System.out.println("File permission: "+infos.getPermission());
 System.out.println("File Replication: "+infos.getReplication());
 System.out.println("File Block Size: "+infos.getBlockSize());
 BlockLocation[] blockLocations = fs.getFileBlockLocations(infos, 0, 
infos.getLen());
            for(BlockLocation blockLocation : blockLocations) {
                String[] hosts = blockLocation.getHosts();
                System.out.println("Block offset: " + blockLocation.getOffset());
                System.out.println("Block length: " + blockLocation.getLength());
                System.out.print("Block hosts: ");
                for (String host : hosts) {
                    System.out.print(host + " ");
                }
                System.out.println();
            }
            fs.rename(filepath, newpath);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}