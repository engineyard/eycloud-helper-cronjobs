define :restart_cron do
  execute "restart cron" do
    command "/etc/init.d/vixie-cron restart; exit 0"
  end
end