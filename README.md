
# Project Title

In this project, I created a CI/CD pipeline that automates the development lifecycle. When code is pushed to the Git master branch, it is automatically checked out, compiled, tested, and containerized. A test server is provisioned using Terraform and configured with necessary software via Ansible. After successful deployment to the test server, only then is the process repeated for the production server. Both the test and production servers are monitored using Prometheus Node Exporter, with Grafana dashboards displaying critical metrics like CPU, disk space, and memory usage.


## Overview
![Description of GIF](./assets/gifproj.gif)
