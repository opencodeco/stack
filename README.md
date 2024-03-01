# Stack

🧱 Common infrastructure components in a single command.

## Components

| Component | Description |
| --- | --- |
| `stack mysql`| MySQL & phpMyAdmin (http://localhost:8031) |
| `stack redis` | Redis & RedisInsight (http://localhost:8032) |
| `stack mongo` | MongoDB & Mongo Express (http://localhost:8033) |
| `stack postgres` | PostgreSQL & pgAdmin (http://localhost:8034) |
| `stack kafka` | Kafka and UI for Apache Kafka (http://localhost:8037) |
| `stack rabbitmq` | RabbitMQ & Management Plugin (http://localhost:8038) |
| `stack aws` | AWS services via LocalStack (http://localhost:4566) |
| `stack o11y` | OpenTelemetry Collector, Jaeger UI, Prometheus & Grafana (see below) |

### Observability (o11y)

| Component | Description | Port |
| --- | --- | --- |
| OpenTelemetry Collector | Jaeger HTTP | `14268` |
| OpenTelemetry Collector | Statsd UDP | `8125` |
| OpenTelemetry Collector | OTLP gRPC | `4317` |
| OpenTelemetry Collector | OTLP HTTP | `4318` |
| Jaeger UI | Traces | http://localhost:8034 |
| Prometheus | Metrics | http://localhost:8035 |
| Grafana | Dashboards & Alerts | http://localhost:8036 |

## Commands

| Command | Description |
| --- | --- |
| `stack ls` or `stack ps` | List running containers |
| `stack path` | Display where Stack is located |
| `stack network` | Create the external `opencodeco` network |

## Getting started

### Changing ports

Whether to avoid conflicts or to set a port number that fits best for your enviroment, you can create a `.env` file at `stack path` and change port numbers based on `.env.dist`.

### Install

Just clone this repository:
```shell
git clone https://github.com/opencodeco/stack.git
cd stack
make install
```

### Usage
You can use the built-in Shell Script helper:
```shell
stack <component> <docker compose command>
```

The `<docker compose command>` defaults to `up -d`, so:
```shell
stack mysql
```
Will be the same as:
```shell
stack mysql up -d
```
Which does a:
```shell
docker-compose -d mysql/docker-compose.yml up -d
```
Behind the scenes.

#### Which means you can combine any other valid Docker Compose command

Like:
```shell
stack mysql down
```

Or:
```shell
stack mysql logs -f
```

---

⚠️ **Remember:** this is suited for development environments only.
