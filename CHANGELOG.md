# Ravenx Changelog

## v 1.1.2

* Allow unlinked notifications (thanks to @belaustegui)

## v 1.1.1

* Fix circular dependencies (thanks to @mkaravaev)
* Update dependencies for Elixir 1.5.0
* Use non-retired version of hackney

## v 1.1.0

* Use HTTPoison instead of HTTPotion
* Fix error when using tuple contacts in e-mail strategy

## v 1.0.0

* Add custom strategies support
* Normalize error responses
* Use identifiers as keys in multiple notification dispatching
* Fix issue with e-mail strategy.
* Add tests

## v 0.1.2

* Fix bug that avoid email dispatching using SMTP.

## v 0.1.1

* Add compatibility with `~> 2.0` version of `poison`, that is the required in actual versions of `phoenix`.

## v 0.1.0

* Slack integration
* E-mail integration
* Notification modules support
