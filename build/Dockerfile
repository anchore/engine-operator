FROM quay.io/operator-framework/helm-operator:v0.7.0

LABEL name="Anchore Engine Operator" \
      vendor="Anchore Inc." \
      maintainer="dev@anchore.com" \
      version="v0.1.0" \
      release="1" \
      summary="Anchore Engine OSS helm based operator." \
      description="Anchore Engine - container image scanning service for policy-based security, best-practice and compliance enforcement."

COPY LICENSE /licenses/LICENSE
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts/ ${HOME}/helm-charts/
