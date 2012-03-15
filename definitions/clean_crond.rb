define :clean_crond do
  execute "cleanup crond" do
    command "rm -fr /etc/cron.d/*"
  end
end
