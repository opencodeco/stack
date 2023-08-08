# Stack

🧱 Common infrastructure components in a single command.

## Getting started

### Install

Just clone this repository:
```shell
git clone https://github.com/opencodeco/stack.git
cd stack
```

Then make sure you have a network named `opencodeco`. You can do this by:
```shell
docker network create opencodeco
```

### Usage
You can use the built-in Shell Script helper:
```shell
./stack <component> <docker compose command>
```

The `<docker compose command>` defaults to `up -d`, so:
```shell
./stack mysql
```
Will be same as:
```shell
./stack mysql up -d
```
Which does a:
```shell
docker-compose -d mysql/docker-compose.yml up -d
```
Behind the scenes.

#### Which means you can combine any other valid Docker Compose command

Like:
```shell
./stack mysql down
```

Or:
```shell
./stack mysql logs -f
```

### Components
Here is a list of components:

| Component | Description |
| --- | --- |
| `./stack mysql`| MySQL & phpMyAdmin (http://localhost:3380) |

---

⚠️ **Remember:** this is suited for development environments only.
