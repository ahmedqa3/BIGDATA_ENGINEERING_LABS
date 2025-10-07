package edu.ensias.hadoop.hdfslab;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class WriteHDFS {
    public static void main(String[] args) throws IOException {
        // Vérifier si les arguments sont fournis
        if (args.length < 2) {
            System.err.println("Usage: hadoop jar WriteHDFS.jar <hdfs_file_path> <message>");
            System.err.println("Exemple: hadoop jar WriteHDFS.jar ./input/bonjour.txt \"Mon message\"");
            System.exit(1);
        }

        Configuration conf = new Configuration();
        FileSystem fs = FileSystem.get(conf);
        Path nomcomplet = new Path(args[0]);
        
        // Vérifier si le fichier existe déjà
        if (!fs.exists(nomcomplet)) {
            try {
                // Créer le répertoire parent si nécessaire
                Path parent = nomcomplet.getParent();
                if (parent != null && !fs.exists(parent)) {
                    fs.mkdirs(parent);
                    System.out.println("Répertoire parent créé : " + parent);
                }
                
                // Créer et écrire dans le fichier
                FSDataOutputStream outStream = fs.create(nomcomplet);
                outStream.writeUTF("Bonjour tout le monde !");
                outStream.writeUTF(args[1]);
                outStream.close();
                
                System.out.println("Fichier créé avec succès : " + args[0]);
            } catch (IOException e) {
                System.err.println("Erreur lors de la création du fichier : " + e.getMessage());
                throw e;
            }
        } else {
            System.out.println("Le fichier " + args[0] + " existe déjà sur HDFS.");
        }
        
        fs.close();
    }
}
