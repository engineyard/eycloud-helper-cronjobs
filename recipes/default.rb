#
# Cookbook Name:: cronjobs
# Recipe:: default
#

framework_env = node.engineyard.environment.framework_env
aws_secret_id = node.engineyard.environment.aws_secret_id
aws_secret_key = node.engineyard.environment.aws_secret_key
env_name = node.engineyard.environment.name
owner_name = node[:owner_name]

clean_crond

if ["app_master", "solo"].include?(node[:instance_role])
  crond "Update trial usage" do
    filename "update_trial_usage"
    interval "43 * * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/update_trial_usage|
  end

  crond "Deprovision oustanding services" do
    filename "deprovision_services"
    interval "*/7 * * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/deprovision_services|
  end


  crond "Expire completed trials" do
    filename "expire_completed_trials"
    interval "40 * * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/expire_completed_trials|
  end

  crond "Collect stats" do
    filename "collect_stats"
    interval "*/5 * * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/collect_stats|
  end

  crond "Update gem info" do
    filename "gem_index"
    interval "2 */2 * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} 'Geminfo.fresh_import'|
  end

  crond "Update the default availability zone" do
    filename "update_default_az"
    interval "*/5 * * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/update_default_availability_zone|
  end

  crond "Notify accounts without monitor urls" do
    filename "add_monitor_url_notices"
    interval "15 1 15 * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/add_monitor_url_notices|
  end

  crond "Audit account untracked instances" do
    filename 'audit_account_untracked_ec2_instances'
    interval '19 8 * * *'
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/audit_account_untracked_ec2_instances|
  end

  crond "Validate models" do
    filename 'validate_models'
    interval '46 0 * * *'
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/validate_models|
  end

  crond "Check for unstuck instances" do
    filename 'unstuck_instances_check'
    interval '0 4 * * *'
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/unstuck_instances_check|
  end

  crond "Purge Staff Keys" do
    filename "purge_staff_keys"
    interval "0 2 * * *"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/purge_staff_keys|
  end

  crond "Send reports to funion" do
    filename "funion"
    interval "0 1 * * 0"
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/funion|
  end

  if framework_env == "production"
    crond "Send trial report" do
      filename "beta_report"
      interval "0 8 * * *"
      runner owner_name
      command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/beta_report.rb|
    end
  end

  crond "Check instance hostnames" do
    filename 'instance_hostname_check'
    interval '0 5 * * *'
    runner owner_name
    command %|cd /data/awsm/current && bundle exec ruby script/merb_filter.rb rails runner -e #{framework_env} script/instance_hostname_check|
  end
end

if alert_email = node.engineyard.environment.alert_email
  execute "add MAILTO to cron" do
    command %{(crontab -l; echo "MAILTO=#{alert_email}") |crontab -}
    not_if 'crontab -l | grep -q "^MAILTO"'
  end
end

execute "restart cron" do
  command "/etc/init.d/vixie-cron restart; exit 0"
end
