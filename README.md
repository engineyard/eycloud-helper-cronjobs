# Cronjobs helpers for EY Cloud

Definitions for other recipes to create/maintain/restart cronjobs

## crond definition

Create a cronjob.

Example usage:

``` ruby
crond "Kill stale resque workers" do
  filename "resque_kill_stale"
  interval "* * * * *"
  command %Q{/usr/local/bin/resque_kill_stale /tmp/resque_ttls}
end
```

``` ruby
crond "Collect stats" do
  filename "collect_stats"
  interval "*/5 * * * *"
  runner owner_name
  command %|...|
end
```

## clean_crond definition

Clean up crond.

Usage:

``` ruby
clean_crond
```

## restart_cron definition

Restart cron

Usage

``` ruby
restart_cron
```
