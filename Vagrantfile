# -*- mode: ruby -*-
# vi: set ft=ruby :

# YAML read support is needed for parsing the config file
require 'yaml'
# Network libraries are used for querying the box URL
require 'uri'
require 'net/http'


# Tested with Vagrant 1.5.1, but should also work for 1.4.x
Vagrant.require_version ">= 1.4.0"
VAGRANTFILE_API_VERSION = '2'


#----------------------------------------------------------------------
# Parse the config file
#----------------------------------------------------------------------

# Check for config file
if File.exists?('config.yml')
  cfg = YAML.load_file('config.yml')
else
  abort <<-EOF.gsub(/^ {4}/, '')
    
    Error: no configuration file found!
    
    (Are you in a folder containing a config.yml?)
    
  EOF
end

# Check for mandatory config parameters
['box', 'hostname'].each do |param|
  if !cfg.has_key?(param)
    abort 'Error: mandatory parameter missing in config: ' + param
  end
end


#----------------------------------------------------------------------
# Sanity checks
#----------------------------------------------------------------------

# Check whether line endings in shell scripts were converted to CRLF
# during git cloning
bootstrap_script = File.expand_path(
  File.join(
    File.dirname(__FILE__),
    'debian-wheezy-i386-python3',
    'bootstrap.sh'
  )
)
if !File.exists?(bootstrap_script)
  puts <<-EOF.gsub(/^ {4}/, '')
    Warning: unable to check line endings (bootstrap script not found)
  EOF
else
  if File.open(bootstrap_script, 'rb').read.include? "\r\n"
    abort <<-EOF.gsub(/^ {4}/, '')
      Error: found Windows line feed (CRLF) in the bootstrap script!
      
      This might break the VM provisioning process!
      
      Please check your Git setup and make sure there is a gitattributes
      file setting the correct line feeds for shell scripts.
    EOF
  end
end


#----------------------------------------------------------------------
# As long as custom built base boxes are still used, check for box
# availability and provide meaningful output on errors.
#----------------------------------------------------------------------

if cfg.has_key?('box_url')
  uri = URI(cfg['box_url'])
  
  if uri.host == 'bmorg.io'
    response = nil
    Net::HTTP.start(uri.host, 80) {|http|
      response = http.head(uri.path)
    }
    
    if response.code != '200'
      puts 'Warning: the specified base box has become unavailable at ' +
           'its origin!'
      puts
      puts 'This likely means that the base box for this build has changed.'
      puts 'Please check the original repository for updates.'
      puts
      puts 'The returned status was:'
      puts response.code
      puts response.message
      puts
    end
  end
end


#----------------------------------------------------------------------
# Now for the Vagrant configuration
#----------------------------------------------------------------------

Vagrant.configure(VAGRANTFILE_API_VERSION) do |configure|
  configure.vm.define :machine do |configure|
    
    # The box to base this VM on
    configure.vm.box = cfg['box']
    if cfg.has_key?('box_url')
      configure.vm.box_url = cfg['box_url']
    end
    if cfg.has_key?('box_md5')
      configure.vm.box_download_checksum = cfg['box_md5']
      configure.vm.box_download_checksum_type = 'md5'
    end
    
    # Run the configured provisioners
    cfg['provisioners'].each do |provisioner|
      case provisioner['type']
      
      when 'shell'
        # Set up a shell provisioner
        configure.vm.provision :shell, :path => provisioner['path']
      
      when 'puppet'
        # Set up a Puppet provisioner
        configure.vm.provision "puppet" do |puppet|
          puppet.manifests_path = "puppet"
          puppet.manifest_file = provisioner['manifest']
          puppet.options = [
            "--modulepath",
            "/vagrant/puppet/modules:/vagrant/puppet/forge-modules"
          ]
          puppet.facter = {
            'env_hostname' => cfg['hostname'],
          }
        end
      
      else
        abort "Error: unsupported provisioner: #{provisioner['type']}"
      
      end
    end
    
    # Set the hostname
    configure.vm.host_name = cfg['hostname']
    
    # Set up networking
    # Network type defaults to 'private_network'
    case cfg.fetch('network', 'private')
    
    when 'private'
      # For private network, the interface is ignored
      if cfg.has_key?('ip')
        configure.vm.network 'private_network', ip: cfg['ip']
      else
        # XXX Although this is the exact same as in the docs,
        # Vagrant fails with the following error message:
        # "An IP is required for a private network."
        # http://docs.vagrantup.com/v2/networking/private_network.html
        configure.vm.network 'private_network', type: 'dhcp'
      end
    
    when 'public'
      # For public network respect IP and interface setting
      if cfg.has_key?('ip')
        # IP was configured
        if cfg.has_key?('interface')
          configure.vm.network 'public_network', ip: cfg['ip'],
                               :bridge => cfg['interface']
        else
          configure.vm.network 'public_network', ip: cfg['ip']
        end
      else
        # No IP was configured
        if cfg.has_key?('interface')
          configure.vm.network 'public_network',
                               :bridge => cfg['interface']
        else
          configure.vm.network 'public_network'
        end
      end   
    
    else
      abort "Error: unexpected network type: #{cfg['network']}"
    
    end
    
    # Sync the configured folders
    if cfg['synced_folders']
      cfg['synced_folders'].each do |synced_folder|
        configure.vm.synced_folder \
          synced_folder['host'], \
          synced_folder['guest'], \
          owner: synced_folder['owner'], \
          group: synced_folder['group']
      end
    end
    
    # VirtualBox specific setup
    configure.vm.provider :virtualbox do |vb|
      # Show the VirtualBox GUI on machine startup
      vb.gui = cfg.fetch('virtualbox_gui', false)
      # Set the VM name to the hostname
      vb.name = cfg['hostname']
      
      # Use VBoxManage to customize the VM.
      vb.customize ["modifyvm", :id, "--memory", "1024"]
      #vb.customize ["modifyvm", :id, "--cpus", 2]
    end
    
  end
end
