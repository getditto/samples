# Heartbeat 

HTTP -> Big Peer -> Small Peer -> Big Peer -> CDC

## Installation

```
> npm install
```

## Usage

1. Replace APP_ID and TOKEN in `index.ts` with your values.
1. Replace APP_ID in `heartbeat.sh` with your values.
1. Use with [Change Data Capture](https://docs.ditto.live/http/common/guides/kafka/intro) to create a full end-to-end heartbeat of the ditto system.


```
> npm run build
> node index.js
```

You must run `npm run build` every time you modify `index.ts.

