## Changes

### Version 2.4.11

* Twitter Bootstrap updated to 2.2.1.

### Version 2.4.10

* Log downloads fixed for svlogd mode.
* jQuery update to 1.8.2.
* Vagrant box updated to precise32.

### Version 2.4.9

* Updates of logger policy - demofly
* Knowledge about terabytes - demofly

### Version 2.4.8

* Twitter Bootstrap updated to 2.1.1.
* jQuery updated to 1.8.1.

### Version 2.4.7

* Credentials setup fixed for --rackup option - galetahub

### Version 2.4.6

* GET /services.json API was broken from 2.4.0 release - Bregor.

### Version 2.4.5

* Replace potential incorrect multiline regexps with valid ones. There was no security vulnerabity.
* Minor visual appearance update.

### Version 2.4.4

* Use Twitter Bootstrap styles.

### Version 2.4.1

* New *files to watch* feature that detects and shows watched files that modified since service startup.

### Version 2.4.0

* LogLocationCache completely removed to keep codebase small and readable.
* Code refactoring to support multiple log file downloads and to avoid errors in case of file absence.

### Version 2.3.21

* Running using `bundle exec` is fixed.
* Initial staging environment added using [http://vagrantup.com/](Vagrant "Vagrant").
* Fix internal error when log downloads directory is absent.

### Version 2.3.18

* Bugfixes of log downloads page.

### Version 2.3.15

* Minor stylistic update.
* Minor refactorings, deprecations and fixes.

### Version 2.3.12

* Russian locale updated to meet Psych YAML parser.
* Codebase updated to use modern Sinatra 1.3.
* Minor refactoring.

### Version 2.3.8

* Minor update of handling logger log directories (we should remove last character from log directory name if it equals to ':').
* Enable of using `bundle exec rake ...` command.

### Version 2.3.7

* '--rackup' option now takes in care all specified options (earlier it takes in care only preceding options).
* Registration option now takes in care '--rackup' option.
* Minor refactoring.

### Version 2.3.6

* Internationalization of system information page.
* favicon added.

### Version 2.3.5
* Added /info (system information page).

### Version 2.3.4
* Rack::File used to serve static files in old Sinatra releases (Sinatra 1.3.0 have this functionality built-in). Requires Rack 1.3.0 or higher.
* rainbows configuration now uses sendfile gem if its available to decrease CPU usage on serving large files.

### Version 2.3.3
* Typo (very old one).

### Version 2.3.2
* Thread safety.
* rainbows.conf file provided aside config.ru to optimize running under rainbows application server.

### Version 2.3.1
* New --rackup option to start runit-man using any Rack-compatible server (like unicorn/rainbows).

### Version 2.2.9
* Fix runit-man service registration (bug introduced in 2.2.6).
* Upgrade jQuery to 1.6.1.

### Version 2.2.8
* Encodings handling has been fixed (ruby 1.9 was affected) - prepor

### Version 2.2.7
* Yet another fix for logger applied when no current log file exists.

### Version 2.2.6
* Use standalone ERB instead of Erubis because we now not depend on erubis gem (registration broken in 2.1.1 when erubis is not installed).
* runit run scripts are fixed to use bash instead of any sh (thanks to hackru).

### Version 2.2.5
* Try to show human readable error message when file cannot be parsed in UTF-8 encoding.

### Version 2.2.4
* Fix haml options for ruby 1.8 (bug introduced in yanked 2.2.2)
* Try to show human readable error message when file cannot be parsed in UTF-8 encoding.

### Version 2.2.3 (yanked)
* Upgrade jQuery to 1.6.
* Fix jslint errors and warnings.
* Spawning of tail command replaced with file-tail gem.
* Force UTF-8 encoding on file contents in ruby 1.9.

### Version 2.1.2
* Sometimes we have no current log file in logger (no records in current day). Test for it.
* Updated logic of calculation of log file times.

### Version 2.1.1
* erubis replaced with haml (because newest erubis breaks rendering of page).
* CSS updated.

### Version 2.0.9
* English locale fixed (broken in 2.0.0).
* Caching fixed (broken in 2.0.7).

### Version 2.0.7
* Caching of logger log locations removed, other caching was shortened.

### Version 2.0.6
* Support for gzipped logs.

### Version 2.0.2
* Fix log link hint, thats broken from 1.11.x (thanks to verm666).

### Version 2.0.1
* Use Bundler to simplify development tasks.
* Fix registration of -l option.

### Version 2.0.0
* Support for logger utility in addition to svlogd utility
* jQuery upgraded to version 1.5.2.

### Version 1.11.6
* New column (started_at) has been added.

### Version 1.11.4
* jQuery upgraded to version 1.5.1.
* Fixed i18n for en locale in log view (bug introduced in 1.11.0).
* Minor typo in ru locale.

### Version 1.11.3
* Fixed i18n for file view (bug introduced in 1.11.0).

### Version 1.11.0
* Switched from sinatra-r18n gem to i18n gem due to various aperiodic translation problems.

### Version 1.10.3
* All time information in "Log downloads" section now represented in UTC.
* Downloaded file names for logs now include host name.
* Minor update of visual appearance of "Log downloads" section.

### Version 1.10.2
* Log naming schema in "Log downloads" section has been changed to be more friendly.
* Special svlogd "state" and "newstate" files are skipped in Downloads section.
* Minor fix for ruby 1.9.2 in Rakefile (was broken in 1.10.1).

### Version 1.10.1
* X-Powered-By and X-Version response headers added (to simplify management of installations).

### Version 1.10.0
* Ability to download log files of concrete service.

### Version 1.9.8
* jQuery upgraded to version 1.5.0.

### Version 1.9.7
* Useless json gem compatibility layer has been removed.

### Version 1.9.6
* Home has been moved to https://github.com/Undev/runit-man.

### Version 1.9.5
* Support for Ruby 1.9.2.
* Use native Erubis support of Sinatra.
* Switch from sinatra-content-for gem to sinatra-content-for2 gem.

### Version 1.9.4
* Use RSpec 2.

### Version 1.9.3
* jQuery upgraded from version 1.4.2 to version 1.4.4.
* Switch from json gem to yajl-ruby gem.

### Versions 1.9.0 up to 1.9.2
* BasicAuth supported by -u user:password option (multiple occurences allowed).

### Version 1.8.4
* Now status of services read from status file instead of both status and stat.

### Version 1.8.3
* Fix view of files that have extension like '.json', '.html' etc.

### Versions 1.8.1 up to 1.8.2
* Minor visual improvements.

### Version 1.8.0
* Allow to send custom signal through Web interface
  if these specified in SV/runit-man/allowed-signals folder.

### Versions 1.7.0 up to 1.7.4
* Uptime and pid now retrieved from daemontools-compatible status.
* Files are cached.
* Uptime is shown.

### Version 1.6.4
* Fix for new versions of json gem.

### Versions 1.6.0 up to 1.6.3
* Ability to view files and urls associated with service.
* Small fixes. 

### Version 1.5.4
* More correct way to register itself as runit service.

### Version 1.5.3
* Fix link to view file as text/plain.

### Version 1.5.2
* Fix reregistration as runit service.

### Version 1.5.1
* Fix registration as runit service.

### Version 1.5.0
* We can view files in predefined locations (see command line options).

### Version 1.4.9
* More readable description for rubygems.

### Version 1.4.8
* runit-man now supports sending of any signals through API.

### Version 1.4.7
* runit-man now supports output of logs in raw text/plain format.

### Version 1.4.6
* runit-man now can show custom count of lines per log.

### Version 1.4.5
* Fix error when ran on machine when its name cannot be resolved by DNS.
* /services.json added to provide automation API. 

### Version 1.4.3
* Add dependency to nearest r18n library that run on ruby 1.8.6
* Script renamed to runit-man without extension.

### Version 1.4.1
* Workaround for rubygems behavior (sometimes it doesnt update binaries).

### Version 1.4
* Automated registration with given options.

### Version 1.3
* Automated registration as runit service (-r option).

### Version 1.2
* First public release
* Some wrong installed services cannot be switched because installed
  as directories instead of symlinks.

### Version 1.1
* After sending of actions state was retrieved from server too often.
* Performed actions now logged.
* Services now can be activated and deactivated.
* Refactoring of LogLocationCache.
* Locations of runit folders now can be set through command line.

### Version 1.0
* Packaged into gem.
* I18n (en and ru locales added).
* Visual improvements.

### Version 0.2
* Visual improvements.

### Version 0.1
* First working release

