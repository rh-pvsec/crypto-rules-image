FROM scratch

COPY crypto_rules/semgrep-rules /crypto_rules/semgrep-rules

LABEL name="crypto_rules" \
    com.redhat.component="crypto_rules" \
    io.k8s.name="crypto-rules" \
    io.k8s.tags="crypto-rules" \
    summary="ScanOSS crypto_rules used to scan sources and detect cryptographic algorithms." \
    description="ScanOSS crypto_rules used to scan sources and detect cryptographic algorithms." \
    io.k8s.description="ScanOSS crypto_rules used to scan sources and detect cryptographic algorithms." \
    maintainer="exd-guild-security@redhat.com" \
    distribution-scope="public" \
    url="https://github.com/rh-pvsec/crypto_rules-image" \
    vendor="Red Hat, Inc."

