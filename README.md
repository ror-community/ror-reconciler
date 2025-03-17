# Research Organization Registry (ROR) OpenRefine reconciler

This app allows matching data in OpenRefine to ROR according to the [W3C Reconcilation API specification](https://www.w3.org/community/reports/reconciliation/CG-FINAL-specs-0.1-20230321/).

It is essentially a proxy to the ROR API and provides an endpoint that can be used within OpenRefine according to the [OpenRefine Reconciliation docs](https://openrefine.org/docs/manual/reconciling).

For end user information and usage instructions see [ROR documentation: OpenRefine Reconciler](https://ror.readme.io/docs/openrefine-reconciler#usage-instructions)

## Local dev setup

### Pre-requisits
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Install [OpenRefine](https://openrefine.org/)
- Clone this project locally

### Start ROR reconciler locally

1. Start Docker desktop
2. Change to the project directory and run `docker-compose up --build`
3. Check that the reconciler app is running

        curl http://localhost:9292/heartbeat
        {"max_results":5,"named":"ROR Reconciler","status":"OK","pid":"","ruby_version":"2.6.5","phusion":true}

4. [Configure OpenRefine to use the ROR reconciler per docs](https://ror.readme.io/docs/openrefine-reconciler#usage-instructions), but enter http://localhost:9292/reconcile as the service URL.

