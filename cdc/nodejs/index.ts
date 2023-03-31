import { Kafka, CompressionTypes, CompressionCodecs, logLevel } from 'kafkajs';
import * as fs from 'fs';
import LZ4Codec from 'kafkajs-lz4';

CompressionCodecs[CompressionTypes.LZ4] = new LZ4Codec().codec;

const topic = process.env.TOPIC || '';
const kafkaHost =  process.env.CLOUD_ENDPOINT || '';

const kafka = new Kafka({
  clientId: 'my-consumer',
  brokers: [kafkaHost],
  ssl: {
    rejectUnauthorized: false,
    key: fs.readFileSync("./user.key", "utf-8"),
    cert: fs.readFileSync("./user.crt", "utf-8"),
    ca: fs.readFileSync("./cluster.crt", "utf-8"),
  }
});

const consumer = kafka.consumer({ groupId: topic });

const run = async () => {
  await consumer.connect();
  await consumer.subscribe({ topic: topic, fromBeginning: true });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log(`Received message from topic ${topic} and partition ${partition}: ${message.value}`);
    },
  });
};

run().catch(console.error);
