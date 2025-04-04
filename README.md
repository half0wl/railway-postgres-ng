# Railway Postgres

> ⚠️ This repository is a work in progress. All releases are Alpha versions,
> and should not be used unless advised by the Railway team. Use
> [railwayapp-templates/postgres-ssl](https://github.com/railwayapp-templates/postgres-ssl)
> instead.

_Next-generation Postgres for Railway._

- High Availability support via [repmgr](https://repmgr.org/)
- Built-in SSL support; automatic certificate generation and renewal

## Versioning

Releases follow [SemVer](https://semver.org/) and the versioning scheme:

```
rlwy${RAILWAY_VERSION}-pg${PG_VERSION}
```

where `${RAILWAY_VERSION}` is the version of the Railway release, and
`${PG_VERSION}` is the version of Postgres. For example,
`rlwy0.0.1-pg15.12` is Railway 0.0.1 & Postgres 15.12.

## Changelog

### 2025-04-04: rlwy0.0.1

🚀 Initial release based off [railwayapp-templates/postgres-ssl](https://github.com/railwayapp-templates/postgres-ssl)

- Adds support for setting up replication via [repmgr](https://repmgr.org/)
- Postgres versions are now pinned to their respective latest minor versions
  and `bookworm` deb images
- `SSL_CERT_DAYS` is deprecated. This value will be ignored if provided. All
  server certificates will default to 730 days validity
- Root CA certificate expiry is now separated from server certificate expiry

## License

[MIT; Copyright (c) 2025 Railway Corporation https://railway.com](LICENSE)
