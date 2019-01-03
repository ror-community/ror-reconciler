## A simple OpenRefine reconciler for the Research Organization Registry (ROR).

## Cheatsheet to get this working with Docker on your local machine

- `docker build -t ror-reconciler .`
- `docker swarm init`
- `docker stack deploy -c docker-compose.yml ror_reconcile`
- roar! 🦁

## test

`curl http://localhost:4567/heartbeat`

You should see something like:

`{"named":"ROR Reconciler","status":"OK","pid":"1","ruby_version":"2.5.3","phusion":false}`

## To stop

- `docker service ls`
- `docker stack rm ror_reconcile`
- `docker swarm leave --force`
