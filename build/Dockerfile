FROM quay.io/operator-framework/helm-operator:v0.8.1

LABEL name="Anchore Engine Operator" \
      vendor="Anchore Inc." \
      maintainer="dev@anchore.com" \
      version="v0.1.1" \
      release="0" \
      summary="Anchore Engine Helm based operator." \
      description="Anchore Engine - container image scanning service for policy-based security, best-practice and compliance enforcement."

COPY licenses /licenses
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts/ ${HOME}/helm-charts/
