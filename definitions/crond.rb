define :crond, :filename => nil, :runner => nil, :interval => nil, :command => nil do
  unless params[:filename] =~ /^[a-z0-9_]+$/i
    raise "Cron name is invalid"
  end

  params[:runner] ||= node[:owner_name]
  alert_email = node.engineyard.environment.alert_email

  template "/etc/cron.d/#{params[:filename]}" do
    cookbook "cronjobs"
    owner 'root'
    group 'root'
    mode 0644
    source "cron.erb"
    variables({
      :email => alert_email,
      :p => params
    })
    backup 0
  end
end
