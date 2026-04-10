# `stack`

🧱 Common infrastructure components in a single command.

## Getting started

### Installation

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/opencodeco/stack/main/install.sh)"
```

## Components

| Component | Description |
| --- | --- |
| `stack mysql`| MySQL & phpMyAdmin (http://localhost:8031) |
| `stack redis` | Redis & RedisInsight (http://localhost:8032) |
| `stack mongo` | MongoDB & Mongo Express (http://localhost:8033) |
| `stack postgres` | PostgreSQL & pgAdmin (http://localhost:8039) |
| `stack kafka` | Kafka and UI for Apache Kafka (http://localhost:8037) |
| `stack rabbitmq` | RabbitMQ & Management Plugin (http://localhost:8038) |
| `stack aws` | AWS services via LocalStack _(legacy, [see details below](#aws-localstack-vs-ministack))_ (http://localhost:4566) |
| `stack aws-ministack` | AWS services via MiniStack (http://localhost:4567) |
| `stack hyperdx` | HyperDX local (http://localhost:8080) | 
| `stack o11y` | OpenTelemetry Collector, Jaeger UI, Prometheus & Grafana (see below) |

### Observability (o11y)

| Component | Description | Port |
| --- | --- | --- |
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
docker-compose -f mysql/docker-compose.yml up -d
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

### AWS: LocalStack vs MiniStack

| | `stack aws` (LocalStack) | `stack aws-ministack` (MiniStack) |
| --- | --- | --- |
| Free | ⚠️ Core services behind paid plan | ✅ Free forever (MIT) |
| Account / API key | Required | Not required |
| Telemetry | Yes | No |
| Services | 30+ (many paid) | 30+ |

> **`stack aws` (LocalStack) is considered legacy.** LocalStack moved most of its core services behind a paid subscription. `stack aws-ministack` using [MiniStack](https://ministack.org/) is the recommended free alternative — it is a drop-in replacement compatible with any AWS CLI or SDK tool via `--endpoint-url=http://localhost:4567`.

---

⚠️ **Remember:** this is suited for development environments only.

> **Note on upgrades:** Major version upgrades for MySQL (8→9), MongoDB (6→8), and RabbitMQ (3→4) may require recreating volumes if you have existing data. Run `stack <component> down -v` to remove volumes before upgrading.
