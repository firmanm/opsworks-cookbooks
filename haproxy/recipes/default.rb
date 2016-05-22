#Install software-properties-common if not installed
package 'software-properties-common' do
  action :install
end

#Add PPA for haproxy 1.6 and update repo
execute "add-ppa-update" do
  command "add-apt-repository ppa:vbernat/haproxy-1.6 && apt-get update -y"
  action :run
end

package "haproxy" do
  retries 3
  retry_delay 5

  version '1.6.4-3ppa1~trusty'
  action  :install
end

if platform?('debian','ubuntu')
  template '/etc/default/haproxy' do
    source 'haproxy-default.erb'
    owner 'root'
    group 'root'
    mode 0644
  end
end

include_recipe 'haproxy::service'

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[haproxy]"
end

template "/etc/haproxy/server.pem" do
  source    "server.pem.erb"
  owner     'root'
  group     'root'
  mode      0600
  notifies  :restart, "service[haproxy]"
end

service 'haproxy' do
  action [:enable, :start]
end
