<div align="center">
  <picture>
    <source srcset="assets/kafka+regatta-dark.png" media="(prefers-color-scheme: dark)">
    <source srcset="assets/kafka+regatta-light.png" media="(prefers-color-scheme: light)">
    <img src="assets/kafka+regatta-dark.png" alt="Banner" title="Banner" style="width:65%;">
  </picture>
</div>

# Docker Kafka Cluster to Regatta Cluster via Sink Connector

This project demonstrates connecting a Docker-based Kafka Cluster to a Regatta Cluster using a Kafka Sink Connector. Please note that this setup does not utilize Kafka Cloud services.

## Limitations
- **Insert-only Support**: Currently, the Regatta Sink Connector supports only insert operations.
- **Delivery Guarantee**: Only "at least once" delivery is supported.
- **Record Format**: AVRO is the only supported record type.

## Prerequisites
- Request the Kafka Sink Connector from the Regatta support team.

## Instructions

### 1. Create a Regatta Cluster

1. **Access the Regatta Platform**:
   - Visit the [Regatta Platform](https://cloud.regatta.dev/) and log in using your registered credentials.
   - If you use a Google-linked email, you can use the Single-Sign-On (SSO) option with Google.

2. **Create a New Cluster**:
   - Click on the "**+ CREATE NEW CLUSTER**" button.
   - Configure the cluster:
     - **Cluster Name**: Provide a meaningful name.
     - **Cluster Type**: Choose the appropriate type based on your requirements.
   - Click "**Confirm**" to create the cluster.

3. **Wait for the Cluster to Run**:
   - Monitor the cluster status. It will change from "**Starting**" to "**Running**" once ready.

### 2. Clone the Repository
Clone this repository to your local machine:
```shell
git clone <repository-url>
```

### 3. Add the Regatta Sink Connector
Place the Regatta Sink Connector file into the cloned repository.

### 4. Update the `sink.json` File
Edit the `sink.json` configuration file:
- Set the "**url**" field to your cluster’s URL (IP:PORT), as shown on the Regatta Platform.
- Provide your "**username**" and "**password**". If you do not have credentials, contact the Regatta support team.

### 5. Build the Docker Compose Setup
Build the Docker images:
```shell
docker-compose build
```

### 6. Start the Docker Compose Services
Run the Docker containers:
```shell
docker-compose up -d
```

Expected ouput:
```shell
/home/michael-ab/.local/lib/python3.6/site-packages/paramiko/transport.py:33: CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography. The next release of cryptography will remove support for Python 3.6.
  from cryptography.hazmat.backends import default_backend
/home/michael-ab/.local/lib/python3.6/site-packages/paramiko/transport.py:236: CryptographyDeprecationWarning: Blowfish has been deprecated
  "class": algorithms.Blowfish,
Starting broker ... done
Starting schema-registry ... done
Starting rest-proxy                  ... done                                                                               Starting connect         ... done
Starting ksqldb-server               ... done
Starting kafka-sink-app_prometheus_1 ... done
Starting control-center              ... done
Starting ksqldb-cli                  ... done
Starting ksql-datagen                ... done
```

### 7. Copy the Sink Connector to the Kafka Connect Container
Transfer the Sink Connector JAR file to the Kafka Connect container. Replace `SINK_CONNECTOR_VERSION` with your version:
```shell
docker cp regatta-sink-connector-{SINK_CONNECTOR_VERSION}-shaded_full.jar connect:/usr/share/java/
```

### 8. Restart the Kafka Connect Container
```shell
docker restart connect
```

### 9. Verify the Kafka Connect API: After the container restarts, ensure the Kafka Connect REST API is accessible
If the curl command failed, it
maybe because your Kafka cluster is still loading, try the curl command again
```shell
curl http://localhost:8083/connectors
```

Expected output:
```shell
[]
```

### 10. Launch the Datagen Source Connector
Start the Source Connector using a POST request.
```shell
curl -X POST -H "Content-Type: application/json" --data @./datagen.json http://localhost:8083/connectors
```

OUTPUT:
```Shell
{"name":"datagen-pageviews","config":{"connector.class":"io.confluent.kafka.connect.datagen.DatagenConnector","kafka.topic":"pageviews","quickstart":"pageviews","key.converter":"io.confluent.connect.avro.AvroConverter","key.converter.schema.registry.url":"http://schema-registry:8081","value.converter":"io.confluent.connect.avro.AvroConverter","value.converter.schema.registry.url":"http://schema-registry:8081","tasks.max":"1","max.interval":"20","iterations":"-1","name":"datagen-pageviews"},"tasks":[],"type":"source"}[
```

### 11. Launch the Sink Connector
Start the Sink Connector using a POST request:
```shell
curl -X POST -H "Content-Type: application/json" --data @./sink.json http://localhost:8083/connectors
```

Expected ouput
```shell
{"name":"test-sink-connector","config":{"connector.class":"dev.regatta.sinkConnector.RegSinkConnector","tasks.max":"1","topics":"pageviews","plugin.path":"/usr/share/java/custom-connector/","rotate.interval.ms":"1000","max.poll.interval.ms":"900000","username":"admin","password":"RegattaDefault1234!","metadataDevice":"m10d0","url":"34.23.121.241:8850","executionTimeout":"4000","maxBatchSize":"1","exactlyOnce":"false","tableName":"pageviews","minNumRecordsToResume":"10000","maxNumRecordsInProcess":"400000","maxThreadsPerPartition":"2","tableAutoCreate":"true","enabledThrottling":"true","enabledMetrics":"false","name":"test-sink-connector"},"tasks":[],"type":"sink"}
```

### 12. Verify Data in the Regatta Cluster
1. Log in to the Regatta Platform and connect to your cluster by clicking the "**Connect**" button.
2. Verify the incoming records. For example, to check the number of rows in the `pageviews` table, run the following query:
   ```sql
   SELECT COUNT(*) FROM pageviews;
   ```
   Example output:
   ```
   Input:
   SELECT COUNT(*) FROM pageviews;

   Output:
   11034
   ```

---

*© 2024 Regatta Team*