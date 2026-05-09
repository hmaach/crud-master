# Security Policy

## Supported Versions

Security updates apply only to the latest stable version.

## Reporting

Email **[hamzamaach56@gmail.com](mailto:hamzamaach56@gmail.com)**. Response within 48h with resolution timeline.

## Notes

- No authentication/authorization implemented.
- All endpoints are public.

## Key Practices

- Store secrets in `.env` (never commit).
- Use HTTPS and secure internal communication in production.
- Validate/sanitize all inputs.
- Keep dependencies updated.
- Run with least privilege.
- Enable logging, monitoring, and backups.

## Current Protections

- SQL injection mitigation via ORM.
- Environment-based config.
- Basic input validation.
- Service separation.

## Planned Improvements

- Auth (API key / JWT).
- HTTPS/TLS.
- Rate limiting.
- Security headers.
- Audit logging.
- Security scanning & testing.
