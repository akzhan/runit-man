## Requirements

You need ruby 1.8.6 or above and rubygems installed.

## Installation

Use following command to install runit-man:

```bash
gem install runit-man
```

Take a look at runit-man script options:

 * -p - Port to listen (4567 by default)
 * -b - IP Address to bind (0.0.0.0 by default)
 * -a - Directory of activated services (/etc/service by default)
 * -f - Directory of all known services (/etc/sv by default)
 * -u - User and password delimited by ':' for HTTP authentication (disabled by default)
 * -r - Register runit-man as runit service (as defined by other options)
 * --rackup='command' - Runs specified command in folder where is runit'man's config.ru located.

### Using thin

Usually you need thin gem to run runit-man effectively.

```bash
gem install thin
```

### Using rainbows

When You need to handle large files (logs etc.) by runit-man script You need another setup:

 * Install rainbows gem (it prevents memory consumption).
 * Install sendfile gem if possible (It decreases CPU usage in combination with rainbows).
 * Run runit-man as:

```bash
runit-man --rackup='rainbows -E production -c rainbows.conf -p $PORT'
```

### Using runit-man cookbook

We provide [runit-man](https://github.com/Undev/runit-man-cookbook) cookbook to automate setup of runit-man using [Opscode Chef](http://www.opscode.com/chef/).

