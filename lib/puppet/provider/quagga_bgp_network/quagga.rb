Puppet::Type.type(:quagga_bgp_network).provide :quagga do
  @doc = %q{ Manages bgp neighbors using quagga }

  commands :vtysh => 'vtysh'

  def self.instances
    debug '[instances]'
    found_config = false
    providers = []
    as = ''
    config = vtysh('-c', 'show running-config')
    config.split(/\n/).collect do |line|
      # Find 'router bgp ...' and store the AS number
      if line =~ /\Arouter\sbgp\s(\d+)\Z/
        as = $1
        found_config = true
      elsif line =~ /\A\snetwork\s([\h\.\/:]+)\Z/
        hash = {}
        network = $1
        hash[:name] = "#{as} #{network}"
        hash[:provider] = self.name
        hash[:ensure] = :present
        debug "bgp network: #{hash}"
        providers << new(hash)
      elsif line =~ /^\w/ and found_config
        break
      end
    end
    providers
  end

  def self.prefetch(resources)
    providers = instances
    resources.keys.each do |name|
      if provider = providers.find{ |provider| provider.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    debug '[create]'

    cmds = []
    as, network = @resource[:name].split(/\s+/)

    cmds << 'configure terminal'
    cmds << "router bgp #{as}"

    if network.include?(':')
      cmds << "ipv6 bgp network #{network}"
    else
      cmds << "network #{network}"
    end

    cmds << 'end'
    cmds << 'write memory'

    vtysh(cmds.reduce([]){ |cmds, cmd| cmds << '-c' << cmd })

    @property_hash[:name] = @resource[:name]
    @property_hash[:ensure] = :present
  end

  def destroy
    debug '[destroy]'

    cmds = []
    as, network = @property_hash[:name].split(/\s+/)

    cmds << 'configure terminal'
    cmds << "router bgp #{as}"

    if network.include?(':')
      cmds << "no ipv6 bgp network #{network}"
    else
      cmds << "no network #{network}"
    end

    cmds << 'end'
    cmds << 'write memory'

    vtysh(cmds.reduce([]){ |cmds, cmd| cmds << '-c' << cmd })

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end