# Front-End
FROM node:12-alpine
WORKDIR /app

ARG DSPACE_REFSPEC=dspace-7.2
ENV DSPACE_HOST 0.0.0.0

ARG DSPACE_REST_HOST=digipres.dspace.lib.unb.ca
ARG DSPACE_REST_NAMESPACE=/server
ARG DSPACE_REST_PORT=443
ARG DSPACE_REST_SSL=true

COPY build /build
RUN apk --no-cache add \
    git \
    postfix \
    rsync \
    util-linux && \
  mv /build/scripts /scripts && \
  cat /build/config/postfix/main.cf >> /etc/postfix/main.cf && \
  postfix start && \
  git clone --depth 1 --branch ${DSPACE_REFSPEC} https://github.com/DSpace/dspace-angular.git /tmpDSpace && \
  rsync -a /tmpDSpace/ /app/ && \
  yarn install --network-timeout 300000 && \
  yarn run build:prod

EXPOSE 4000

CMD ["/scripts/run.sh"]

# Metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL ca.unb.lib.generator="nginx" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="MIT" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.description="digipres.lib.unb.ca is an institutional repository initiative of UNB Libraries intended to collect, preserve, showcase, and promote the open access scholarly output of the UNB community." \
  org.label-schema.name="digipres.lib.unb.ca" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/unb-libraries/digipres.lib.unb.ca" \
  org.label-schema.vendor="University of New Brunswick Libraries" \
  org.label-schema.version=$VERSION \
  org.opencontainers.image.source="https://github.com/unb-libraries/digipres.lib.unb.ca"
