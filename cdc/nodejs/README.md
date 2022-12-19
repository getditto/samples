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
Enter Import Password:
MAC verified OK
❯ openssl x509 -in cluster.crt.pem -out cluster.crt
❯ openssl pkcs12 -in user.p12 -out user.key.pem -nocerts
Enter Import Password:
MAC verified OK
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
❯ openssl pkey -in user.key.pem -out user.key
Enter pass phrase for user.key.pem:
```

Then, run the script:


```
npm run build
node index.js
```

