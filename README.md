# crypto_rules-image

## Introduction

Downstream repository to build an image with proprietary crypto rules from <https://github.com/scanoss/crypto_rules/>

This is being published in a private repo in <docker://quay.io/exd-guild-security/crypto-rules-image:latest>

## Contributing

After cloning, install the pre-commit hooks to prevent accidental secret leakage:

```bash
pip install pre-commit
pre-commit install
```

This repository is enrolled in [Fullsend](https://fullsend.dev) for automated issue triage and implementation.
