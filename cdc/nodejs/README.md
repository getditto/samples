### Installation

```
npm i
```

###  Setup

You need to set the following environment variables:

* `TOPIC`: The Kafka Topic
* `CLOUD_ENDPOINT`: The Kafka endpoint

### Usage

Once the environment variables are set, convert the .p12 files to the required `user.key`, `cluster.crt`, and `user.crt` files:

```
❯ openssl pkcs12 -in cluster.p12 -out cluster.crt.pem -nokeys
❯ openssl x509 -in cluster.crt.pem -out cluster.crt
❯ openssl pkcs12 -in user.p12 -out user.crt -clcerts
❯ openssl pkcs12 -in user.p12 -out user.key.pem -nocerts
❯ openssl pkey -in user.key.pem -out user.key
```

Then, run the script:


```
npm run build
node index.js
```

