# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

## [1.1.0] - 2018-01-24
### Added
- metrics-springboot.rb: new option `--protocol` to allow specifying https connection for requests  (@seanrobb)
- metrics-springboot.rb: new option `--url` to be used as a single parameter instead of specifying `--protocol`, `--host`, `--port`, and `--path` (@seanrobb)

### Changed
- updated changelog guidelines location (@majormoses)

### Fixed
- spelling in PR template (@majormoses)

## [1.0.0] - 2017-06-25
### Added
- Support for Ruby 2.3 and 2.4 (@eheydrick)

### Removed
- Support for Ruby < 2 (@eheydrick)

### Changed
- Loosen `sensu-plugin` dependency to `~> 1.2` (@mattyjones)
- Update to Rubocop `0.40` and cleanup (@eheydrick)

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-03
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-05-20
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-springboot/compare/1.0.0...HEAD
[1.1.0]: https://github.com/sensu-plugins/sensu-plugins-springboot/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-springboot/compare/0.0.3...1.0.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-springboot/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-springboot/compare/0.0.1...0.0.2
