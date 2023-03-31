# Heartbeat 

Monitor the status of Ditto on the cloud and locally.

HTTP -> Big Peer -> Small Peer -> Big Peer -> CDC

## Installation

```
> npm install
```

## Usage

1. Replace APP_ID and TOKEN in `index.ts` with your values.
1. Replace APP_ID in `heartbeat.sh` with your values.
1. Use with [Change Data Capture](https://docs.ditto.live/http/common/guides/kafka/intro) to create a full end-to-end heartbeat of the ditto system.

> *Note: You must run `npm run build` every time you modify `index.ts`.*


```
npm run build
node index.js
```

In a separate terminal, run the heartbeat. This script will send an HTTP request to the Big Peer every 10 seconds.

```
./heartbeat.sh
```
