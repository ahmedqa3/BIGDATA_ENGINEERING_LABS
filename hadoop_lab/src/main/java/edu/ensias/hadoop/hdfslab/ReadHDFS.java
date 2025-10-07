package edu.ensias.hadoop.hdfslab;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class ReadHDFS {
    public static void main(String[] args) throws IOException {
        // Vérifier si un nom de fichier est fourni en paramètre
        if (args.length < 1) {
            System.err.println("Usage: hadoop jar ReadHDFS.jar <hdfs_file_path>");
            System.err.println("Exemple: hadoop jar ReadHDFS.jar ./purchases.txt");
            System.exit(1);
        }

        String fileName = args[0];
        Configuration conf = new Configuration();
        FileSystem fs = FileSystem.get(conf);
        Path nomcomplet = new Path(fileName);

        // Vérifier si le fichier existe
        if (!fs.exists(nomcomplet)) {
            System.err.println("Erreur : le fichier '" + fileName + "' n'existe pas sur HDFS.");
            fs.close();
            System.exit(1);
        }

        FSDataInputStream inStream = fs.open(nomcomplet);
        InputStreamReader isr = new InputStreamReader(inStream);
        BufferedReader br = new BufferedReader(isr);
        String line = null;
        
        // Lire et afficher toutes les lignes du fichier
        while ((line = br.readLine()) != null) {
            System.out.println(line);
        }
        
        // Fermer les flux
        br.close();
        isr.close();
        inStream.close();
        fs.close();
    }
}