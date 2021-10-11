property :app_name, String, name_property:true

default_action :setup

action :setup do
  
  package "letsencrypt"
  package "strongswan"

  if node["platform"] == "ubuntu" and (node["platform_version"] == "18.04" or node["platform_version"] == "20.04")
    package "libstrongswan-extra-plugins"
    package "libcharon-standard-plugins"
    package "libcharon-extra-plugins"
  else
    package "strongswan-plugin-eap-radius"
    package "strongswan-plugin-curl"
  end
  
  execute 'create certificates using letsencrypt' do
      command "letsencrypt certonly --standalone -d #{node['vpn']['ipsec']['fqdn']} -m systems@go-jek.com --agree-tos"
      not_if { ::File.file?("/etc/letsencrypt/live/#{node['vpn']['ipsec']['fqdn']}/privkey.pem") }
  end

  execute 'copy private key to /etc/ipsec.d/private/' do
    command "cp /etc/letsencrypt/live/#{node['vpn']['ipsec']['fqdn']}/privkey.pem /etc/ipsec.d/private/#{node['vpn']['ipsec']['fqdn']}.pem"
  end
  
  execute 'copy certificates to /etc/ipsec.d/certs/' do
    command "cp /etc/letsencrypt/live/#{node['vpn']['ipsec']['fqdn']}/cert.pem /etc/ipsec.d/certs/#{node['vpn']['ipsec']['fqdn']}.pem"
  end
     
  if app_name == "ipsec"
    remote_file '/etc/ipsec.d/cacerts/lets-encrypt-x3-cross-signed.pem' do
      source 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt'
      action :create
    end
  
    execute 'Copy DST Root CA to Strongswan' do
      command 'cp /etc/ssl/certs/DST_Root_CA_X3.pem /etc/ipsec.d/cacerts/DST_Root_CA_X3.pem'
    end
  
    template "/etc/ipsec.conf" do
        source "default/ipsec/ipsec.conf.erb"
    end

    template "/etc/ipsec.secrets" do
        source "default/ipsec/ipsec.secrets.erb"
    end

    template "/etc/strongswan.d/charon/eap-radius.conf" do
        source "default/ipsec/eap-radius.conf.erb"
    end
    
    execute "uncomment the ip forward in sysctl.conf" do
        command "sed  -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf"
    end

    execute "load sysctl" do
      command "sysctl -p"
    end

  else app_name == "ipsec_radius"
    
    remote_file '/etc/ipsec.d/cacerts/isrgrootx1.pem' do
      source 'https://letsencrypt.org/certs/isrgrootx1.pem.txt'
      action :create
    end

    remote_file '/etc/ipsec.d/cacerts/letsencryptauthorityx3.pem' do
      source 'https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt'
      action :create
    end
  
    template "/etc/ipsec.conf" do
        source "default/ipsec-radius/ipsec.conf.erb"
    end

    template "/etc/ipsec.secrets" do
        source "default/ipsec-radius/ipsec.secrets.erb"
    end
      
  end
  
  service "strongswan" do
    action [:enable, :restart]
  end
  
end

