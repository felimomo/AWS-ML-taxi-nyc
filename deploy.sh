#!/usr/bin/env bash
set -euo pipefail
cd infra
terraform init
terraform validate
terraform plan
terraform apply -auto-approve