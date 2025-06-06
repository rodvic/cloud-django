# Apache Hudi on AWS Glue

## AWS Glue

> Reference: [AWS Glue](https://aws.amazon.com/glue/)

AWS Glue is a serverless service that makes data integration simpler, faster, and cheaper. You can discover and connect to more than 100 diverse data sources, manage your data in a centralized data catalog, and visually create, run, and monitor data pipelines to load data into your data lakes, data warehouses, and lakehouses.

### AWS Glue Pricing

> Reference: [AWS Glue Pricing](https://aws.amazon.com/glue/pricing/)

Free tier:

- 1 Million objects stored in the AWS Glue Data Catalog.
- 1 Million requests made per month to the AWS Glue Data Catalog.

### Prepare your account for AWS Glue

> Reference: [Setting up IAM permissions for AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/set-up-iam.html)

Set up roles and users:

- Choose IAM users and roles for AWS Glue
  - Selected roles: `AWSGlueServiceRole`
  - Selected users: `proupsauser`
- Grant Amazon S3 access
  - Choose S3 locations
    - Add access to specific Amazon S3 locations
      - Selected S3 locations: `s3://proupsa-bucket/`
    - Data access permissions
      - Select `Read` and `Write` permissions
- Choose a default service role
  - Update the standard AWS Glue service role and set it as the default (recommended)

## Apache Hudi

> Reference: [What is Apache Hudi](https://hudi.apache.org/docs/0.15.0/overview#what-is-apache-hudi)

Apache Hudi (pronounced “hoodie”) is the next generation streaming data lake platform. Hudi brings core warehouse and database functionality directly to a data lake. Hudi provides tables, transactions, efficient upserts/deletes, advanced indexes, ingestion services, data clustering/compaction optimizations, and concurrency all while keeping your data in open source file formats.

### Run spark-shell with Apache Hudi support in Docker

> Reference: [Develop and test AWS Glue 5.0 jobs locally using a Docker container](https://aws.amazon.com/es/blogs/big-data/develop-and-test-aws-glue-5-0-jobs-locally-using-a-docker-container/)

This container image has been tested for AWS Glue 5.0 Spark jobs. The image contains the following:

- Amazon Linux 2023
- AWS Glue ETL Library
- Apache Spark 3.5.4
- Open table format libraries; Apache Iceberg 1.7.1, Apache Hudi 0.15.0, and Delta Lake 3.3.0
- AWS Glue Data Catalog client
- Amazon Redshift connector for Apache Spark
- Amazon DynamoDB connector for Apache Hadoop

To run the container, you need to have Docker installed and configured on your machine. You also need to have your AWS credentials set up in the `./.aws` directory or pass them as environment variables.

> WARNING: AWS region must be set to `eu-west-1` for this container to work properly, mount the `.aws` directory to path `/home/hadoop/.aws` in the container.
> From aws/hudi repository path

```bash
docker run -it --rm \
  -v ./.aws:/home/hadoop/.aws \
  --name glue5_pyspark \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
  public.ecr.aws/glue/aws-glue-libs:5 \
  spark-shell --packages org.apache.hudi:hudi-spark3.5-bundle_2.12:0.15.0 \
  --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' \
  --conf 'spark.sql.catalog.spark_catalog=org.apache.spark.sql.hudi.catalog.HoodieCatalog' \
  --conf 'spark.sql.extensions=org.apache.spark.sql.hudi.HoodieSparkSessionExtension' \
  --conf 'spark.kryo.registrator=org.apache.spark.HoodieSparkKryoRegistrar' \
  --conf 'spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog' \
  --conf 'spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog'
```

> Note: Replace `${AWS_ACCESS_KEY_ID}`, `${AWS_SECRET_ACCESS_KEY}`, and `${AWS_DEFAULT_REGION}` with your actual AWS credentials and region.

### Insert data into Hudi table using spark-shell from DataFrame

> Reference: [Spark Quick Start](https://hudi.apache.org/docs/0.15.0/quick-start-guide)

This guide provides a quick peek at Hudi's capabilities using Spark. Using Spark Datasource APIs(both scala and python) and using Spark SQL, we will walk through code snippets that allows you to insert, update, delete and query a Hudi table.

- Setup project

Below, we do imports and setup the table name and corresponding base path.

```scala
import scala.collection.JavaConversions._
import org.apache.spark.sql.SaveMode._
import org.apache.hudi.DataSourceReadOptions._
import org.apache.hudi.DataSourceWriteOptions._
import org.apache.hudi.common.table.HoodieTableConfig._
import org.apache.hudi.config.HoodieWriteConfig._
import org.apache.hudi.keygen.constant.KeyGeneratorOptions._
import org.apache.hudi.common.model.HoodieRecord
import spark.implicits._

val tableName = "trips_table"
val dbName = "trips_db"
val basePath = "s3://proupsa-bucket/trips_db/trips_table"
```

- Insert data:

Generate some new records as a DataFrame and write the DataFrame into a Hudi table. Since, this is the first write, it will also auto-create the table.

```scala
val columns = Seq("ts","uuid","rider","driver","fare","city")
val data =
  Seq((1695159649087L,"334e26e9-8355-45cc-97c6-c31daf0df330","rider-A","driver-K",19.10,"san_francisco"),
    (1695091554788L,"e96c4396-3fad-413a-a942-4cb36106d721","rider-C","driver-M",27.70 ,"san_francisco"),
    (1695046462179L,"9909a8b1-2d15-4d3d-8ec9-efc48c536a00","rider-D","driver-L",33.90 ,"san_francisco"),
    (1695516137016L,"e3cf430c-889d-4015-bc98-59bdce1e530c","rider-F","driver-P",34.15,"sao_paulo"),
    (1695115999911L,"c8abbe79-8d89-47ea-b4ce-4d224bae5bfa","rider-J","driver-T",17.85,"chennai"));

var inserts = spark.createDataFrame(data).toDF(columns:_*)
inserts.write.format("hudi")
  .option("hoodie.table.name", tableName)
  .option("hoodie.database.name", dbName)
  .option("hoodie.datasource.write.table.type", "COPY_ON_WRITE")
  .option("hoodie.datasource.write.recordkey.field", "uuid")
  .option("hoodie.datasource.write.partitionpath.field", "city")
  .option("hoodie.datasource.write.precombine.field", "ts")
  .option("hoodie.datasource.write.hive_style_partitioning", "true")
  .option("hoodie.datasource.write.operation", "upsert")
  .option("hoodie.datasource.hive_sync.enable", "true")
  .option("hoodie.datasource.hive_sync.database", dbName)
  .option("hoodie.datasource.hive_sync.table", tableName)
  .option("hoodie.datasource.hive_sync.partition_fields", "city")
  .option("hoodie.datasource.hive_sync.partition_extractor_class", "org.apache.hudi.hive.MultiPartKeysValueExtractor")
  .option("hoodie.datasource.hive_sync.use_jdbc", "false")
  .option("hoodie.datasource.hive_sync.mode", "hms")
  .mode("overwrite")
  .save(basePath)
```

- Query data

Hudi tables can be queried back into a DataFrame or Spark SQL.

```scala
val tripsDF = spark.read.format("hudi").load(basePath)
tripsDF.createOrReplaceTempView("trips_table")

spark.sql("SELECT uuid, fare, ts, rider, driver, city FROM trips_table WHERE fare > 20.0").show()
spark.sql("SELECT _hoodie_commit_time, _hoodie_record_key, _hoodie_partition_path, rider, driver, fare FROM  trips_table").show()
```

- Update data

Hudi tables can be updated by streaming in a DataFrame or using a standard UPDATE statement.

```scala
// Lets read data from target Hudi table, modify fare column for rider-D and update it. 
val updatesDf = spark.read.format("hudi").load(basePath).filter($"rider" === "rider-D").withColumn("fare", col("fare") * 10)

updatesDf.write.format("hudi")
  .option("hoodie.table.name", tableName)
  .option("hoodie.database.name", dbName)
  .option("hoodie.datasource.write.table.type", "COPY_ON_WRITE")
  .option("hoodie.datasource.write.recordkey.field", "uuid")
  .option("hoodie.datasource.write.partitionpath.field", "city")
  .option("hoodie.datasource.write.precombine.field", "ts")
  .option("hoodie.datasource.write.hive_style_partitioning", "true")
  .option("hoodie.datasource.write.operation", "upsert")
  .option("hoodie.datasource.hive_sync.enable", "true")
  .option("hoodie.datasource.hive_sync.database", dbName)
  .option("hoodie.datasource.hive_sync.table", tableName)
  .option("hoodie.datasource.hive_sync.partition_fields", "city")
  .option("hoodie.datasource.hive_sync.partition_extractor_class", "org.apache.hudi.hive.MultiPartKeysValueExtractor")
  .option("hoodie.datasource.hive_sync.use_jdbc", "false")
  .option("hoodie.datasource.hive_sync.mode", "hms")
  .mode(Append)
  .save(basePath)
```

- Read a Hudi table from S3 using a Spark DataFrame:

```scala
val dataFrame = spark.read.format("hudi").load(basePath)
dataFrame.show()
```

### Insert data into Hudi table using spark-shell from CSV file

> Reference: [Using the Hudi framework in AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-format-hudi.html)

You can use AWS Glue to perform read and write operations on Hudi tables in Amazon S3, or work with Hudi tables using the AWS Glue Data Catalog. Additional operations including insert, update, and all of the Apache Spark operations are also supported.

- Upload example CSV file to S3 bucket from local machine:

> From aws/hudi repository path

```bash
aws s3 cp people.csv s3://proupsa-bucket/people.csv
```

- Create a Hudi table from a CSV file and register it to Glue Data Catalog:

```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.col

// Read CSV file from S3
val inputPath = "s3://proupsa-bucket/people.csv"
val df = spark.read.option("header", "true").csv(inputPath)
  .withColumn("ts", col("ts").cast("long"))
  .withColumn("fecha", col("fecha").cast("string"))

// Write DataFrame to Hudi table and register it to Glue Data Catalog
val outputPath = "s3://proupsa-bucket/people_hudi_table"
df.write.format("hudi")
  .option("hoodie.table.name", "people_hudi_db")
  .option("hoodie.database.name", "people_hudi_table")
  .option("hoodie.datasource.write.table.type", "COPY_ON_WRITE")
  .option("hoodie.datasource.write.recordkey.field", "id")
  .option("hoodie.datasource.write.partitionpath.field", "fecha")
  .option("hoodie.datasource.write.precombine.field", "ts")
  .option("hoodie.datasource.write.hive_style_partitioning", "true")
  .option("hoodie.datasource.write.operation", "upsert")
  .option("hoodie.datasource.hive_sync.enable", "true")
  .option("hoodie.datasource.hive_sync.database", "people_hudi_db")
  .option("hoodie.datasource.hive_sync.table", "people_hudi_table")
  .option("hoodie.datasource.hive_sync.partition_fields", "fecha")
  .option("hoodie.datasource.hive_sync.partition_extractor_class", "org.apache.hudi.hive.MultiPartKeysValueExtractor")
  .option("hoodie.datasource.hive_sync.use_jdbc", "false")
  .option("hoodie.datasource.hive_sync.mode", "hms")
  .mode("overwrite")
  .save(outputPath)
```

- List databases in Glue Data Catalog:

```scala
spark.sql("SHOW DATABASES").show()
```

- List tables in the `people_hudi_db` database:

```scala
spark.sql("SHOW TABLES IN people_hudi_db").show()
```

- Get data from Hudi table on Glue Data Catalog:

```scala
spark.sql("SELECT * FROM people_hudi_db.people_hudi_table").show()
```
