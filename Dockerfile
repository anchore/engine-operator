# Build the manager binary
FROM quay.io/operator-framework/helm-operator:v1.4.0

LABEL name="Anchore Engine Operator" \
      vendor="Anchore Inc." \
      maintainer="dev@anchore.com" \
      version="v0.2.0" \
      release="0" \
      summary="Anchore Engine Helm based operator." \
      description="Anchore Engine - container image scanning service for policy-based security, best-practice and compliance enforcement."

ENV HOME=/opt/helm
COPY licenses /licesnses
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}
