## A simple OpenRefine reconciler for the Research Organization Registry (ROR).

This repository is for the code behind ROR's OpenRefine reconciler end-point.

Of course you don't need to actually build/install this to use the reconciler. Instead you can simply add the following URL to your list of OpenRefine reconcilers:

`https://reconcile.ror.org/reconcile`

And use the following “Refine Expression Language” command for creating a new column of ROR ids:

`cell.recon.match.id`

But if you really want to install and work with the reconciler locally, you can follow the cheatsheet below to run the reconciler in Docker.

## Cheatsheet to get reconciler server working with Docker on your local machine

- `docker build -t ror-reconciler .`
- `docker swarm init`
- `docker stack deploy -c docker-compose.yml ror_reconcile`
- roar! 🦁

## test

`curl http://localhost:9292/heartbeat`

You should see something like:

`{"named":"ROR Reconciler","status":"OK","pid":"1","ruby_version":"2.5.3","phusion":false}`

## To stop

- `docker service ls`
- `docker stack rm ror_reconcile`
- `docker swarm leave --force`
