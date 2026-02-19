# Changelog

All notable changes to the SWDCK library will be documented here.

## [1.0.0] - 2024-02-19

This is the initial documentation release, focusing on providing a comprehensive guide for all core features.

### Added
- **Core Engine**: Stable Gateway and REST API implementation.
- **Modern Concurrency**: Full `async/await` support throughout the library.
- **Components V2**: Support for buttons, select menus, and modals.
- **Slash Commands**: Automated registration and easy interaction handling.
- **Type Safety**: Comprehensive models for most Discord API v10 entities.
- **Embed Builder**: A convenient DSL-like builder for rich message content.

### Fixed
- Fixed heartbeat jitter on high-latency connections.
- Improved decoding reliability for optional fields in `Guild` and `Member` models.

---

> 💡 **Note:** Future updates will follow [Semantic Versioning](https://semver.org/).
