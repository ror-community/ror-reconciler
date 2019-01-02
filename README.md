## A simple OpenRefine reconciler for funder names.

See details on the Crossref labs page:

https://www.crossref.org/labs/fundref-reconciliation-service/

Watch the video to see how to use this reconciler server with OpenRefine.

## Cheatsheet to get this working with Docker on your local machine

- `docker build -t funder-reconciler .`
- `docker swarm init`
- `docker stack deploy -c docker-compose.yml funder_reconcile`

## test

`curl http://localhost:4567/heartbeat`

You should see something like:

`{"status":"OK","pid":"1","ruby_version":"2.5.3","phusion":false}`


## To stop

- `docker service ls`
- `docker stack rm funder_reconcile`
- `docker swarm leave --force`
