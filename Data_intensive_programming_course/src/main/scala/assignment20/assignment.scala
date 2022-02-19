package assignment20

import org.apache.spark.SparkConf
import org.apache.spark.sql.functions.{window, column, desc, col}


import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.Column
import org.apache.spark.sql.Row
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.types.StructType
import org.apache.spark.sql.types.{ArrayType, StringType, StructField, IntegerType, DoubleType}
import org.apache.spark.sql.types.DataType
import org.apache.spark.sql.functions.col
import org.apache.spark.sql.functions.{count, sum, min, max, asc, desc, udf, to_date, avg}

import org.apache.spark.sql.functions.explode
import org.apache.spark.sql.functions.array
import org.apache.spark.sql.SparkSession

import org.apache.spark.storage.StorageLevel
import org.apache.spark.streaming.{Seconds, StreamingContext}




import org.apache.spark.ml.feature.VectorAssembler
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.clustering.{KMeans, KMeansSummary}


import java.io.{PrintWriter, File}


//import java.lang.Thread
import sys.process._


import org.apache.log4j.Logger
import org.apache.log4j.Level
import scala.collection.immutable.Range

import org.apache.spark.ml.feature.StringIndexer

object assignment  {
  // Suppress the log messages:
  Logger.getLogger("org").setLevel(Level.OFF)
                       
  
  val spark = SparkSession.builder()
                          .appName("Harkkatyo")
                          .config("spark.driver.host", "localhost")
                          .master("local")
                          .getOrCreate()
  import spark.implicits._
  spark.conf.set("spark.sql.shuffle.partitions", "5")
  
  import org.apache.spark.ml.Pipeline
  import org.apache.spark.ml.clustering.KMeans
  
  //Reading csv files                  
  val dataK5D2 =  spark.read                  
  	                   .option("inferSchema","true")
                       .option("header","true")
                       .option("delimiter",",")
                       .csv("data/dataK5D2.csv")
  
                  
  val dataK5D3 =  spark.read
                       .option("inferSchema","true")
                       .option("header","true")
                       .option("delimiter",",")
                       .csv("data/dataK5D3.csv")
  
  //Creating the StringIndexer which indexes the labels
  val indexer = new StringIndexer()
  .setInputCol("LABEL")
  .setOutputCol("LABEL_INT")

  //Changing string labels to numeric
  val dataK5D2WithLabels= indexer.fit(dataK5D2).transform(dataK5D2)
  
  def task1(df: DataFrame, k: Int): Array[(Double,Double)] = {
    
    //Defining columns a,b as features as input for kmeans algorithm
    val vectorAssembler = new VectorAssembler()
                              .setInputCols(Array("a", "b"))
                              .setOutputCol("features")
                              
    //Creating new Pipeline
    val transformationPipeline = new Pipeline()
              .setStages(Array(vectorAssembler))
              
    //Fitting the data into pipeline and doing other pipeline stuff
    val pipeLine = transformationPipeline.fit(df)
    val transformedTraining = pipeLine.transform(df)
    
    //Creating new kmeans model
    val kmeans = new KMeans().setK(k)
                      
    //Fitting the data into kmeans model
    val kmModel = kmeans.fit(transformedTraining)
    
    //Parsing the cluster centers into an array
    val result = kmModel.clusterCenters
    val parsedData = result.map(row => (row.apply(0),row.apply(1)))
    return parsedData
  }

  def task2(df: DataFrame, k: Int): Array[(Double, Double, Double)] = {
    
    // Defining columns a, b and c and output column features.
    val vectorAssembler = new VectorAssembler()
                              .setInputCols(Array("a", "b", "c"))
                              .setOutputCol("features")
                              
    // Doing pipeline stuff                          
    val transformationPipeline = new Pipeline().setStages(Array(vectorAssembler))
    val pipeLine = transformationPipeline.fit(df)
    val transformedTraining = pipeLine.transform(df)
    
    // Creating K-means model
    val kmeans = new KMeans().setK(k)
    
    // Fitting the data into a K-means model
    val kmModel = kmeans.fit(transformedTraining)	
    
    // Creating clustercenters and transforming it to array
    val result = kmModel.clusterCenters
    val parsedData = result.map(row => (row.apply(0),row.apply(1),row.apply(2)))
    
    return parsedData
  }
  
  def task3(df: DataFrame, k: Int): Array[(Double, Double)] = {
    
    //Defining columns a,b and numeric label as features as input for kmeans algorithm
    val vectorAssembler = new VectorAssembler()
                              .setInputCols(Array("a", "b", "LABEL_INT"))
                              .setOutputCol("features")
                              
    
    //Doing pipeline stuff here                          
    val transformationPipeline = new Pipeline().setStages(Array(vectorAssembler))          
    val pipeLine = transformationPipeline.fit(df)
    val transformedTraining = pipeLine.transform(df)
    
    //Creating new kmeans model
    val kmeans = new KMeans().setK(k)
    
    // Fitting the data into kmeans model
    val kmModel = kmeans.fit(transformedTraining)
    
    // Parsing clustercenters into row and then filtering third element which describes amount of labels.
    // Finally we take elements a and b(first and second elements)
    val result = kmModel.clusterCenters.map(m => (m(0), m(1),m(2))).filter(_._3 > 0.7).map(v => (v._1, v._2))
    
    return result
  }
  
  
  def task4(df: DataFrame, low: Int, high: Int): Array[(Int, Double)]  = {
    
    // Defining columns a and b as features as input for kmeans algorithms
    val vectorAssembler = new VectorAssembler()
                              .setInputCols(Array("a", "b"))
                              .setOutputCol("features")
                              
    
    //Doing pipeline stuff here                          
    val transformationPipeline = new Pipeline().setStages(Array(vectorAssembler))
    val pipeLine = transformationPipeline.fit(df)
    val transformedTraining = pipeLine.transform(df)
    
    // Creating result array with null values
    var costs =  new Array[(Int, Double)](high-low +1)
    
    var i = low // first k-means parameter
    var j = 0   // row index of result array
    
    // Computes cost of clusters for between low < k < high, where k is number of clusters
    for (i<-low to high){
        val kmeans = new KMeans().setK(i)
        val model = kmeans.fit(transformedTraining)
        val cost = model.computeCost(transformedTraining)
        val tuple = (i, cost)
        costs(j) = tuple
        j = j +1
    }
    return costs
  }
    
}





