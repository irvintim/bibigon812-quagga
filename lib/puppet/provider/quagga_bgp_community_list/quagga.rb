Puppet::Type.type(:quagga_bgp_community_list).provide :quagga do
  @doc = 'Manages a community-list using quagga.'

  commands :vtysh => 'vtysh'

  def initialize(value)
    super(value)
    @property_flush = {}
  end

  def self.instances
    providers = []
    hash = {}
    previous_name = ''
    found_community_list = false

    config = vtysh('-c', 'show running-config')
    config.split(/\n/).collect do |line|

      next if line =~ /\A!\Z/

      if line =~ /\Aip\scommunity-list\s(\d+)\s(deny|permit)((\s(\d+:\d+))+)\Z/
        name = $1
        action = $2
        communities = $3.strip.split(/\s/)
        found_community_list = true

        if name != previous_name
          unless hash.empty?
            debug 'Instantiated the bgp community list %{name}.' % {
              :name => hash[:name],
            }

            providers << new(hash)
          end
          hash = {
              :ensure => :present,
              :name => name,
              :provider => self.name,
              :rules => [],
          }
        end

        communities.each do |community|
          hash[:rules] << "#{action} #{community}"
        end

        previous_name = name
      elsif line =~ /\A\w/ and found_community_list
        break
      end
    end

    unless hash.empty?
      debug 'Instantiated the bgp community list %{name}.' % {
        :name => hash[:name],
      }

      providers << new(hash)
    end

    providers
  end

  def self.prefetch(resources)
    providers = instances
    resources.keys.each do |name|
      if provider = providers.find { |provider| provider.name == name }
        resources[name].provider = provider
      end
    end
  end

  def create
    debug 'Creating the bgp community list %{name}.' % {
      :name => @resource[:name],
    }

    cmds = []
    cmds << 'configure terminal'

    @resource[:rules].each do |rule|
      cmds << 'ip community-list %{name} %{rule}' % {
        :name => @resource[:name],
        :rule => rule,
      }
    end

    cmds << 'end'
    cmds << 'write memory'
    vtysh(cmds.reduce([]){ |cmds, cmd| cmds << '-c' << cmd })

    @property_hash[:ensure] = :present
  end

  def destroy
    debug 'Destroying the bgp community list %{name}.' % {
      :name => @property_hash[:name],
    }

    cmds = []
    cmds << 'configure terminal'

    cmds << 'no ip community-list %{name}' % { :name => @property_hash[:name], }

    cmds << 'end'
    cmds << 'write memory'
    vtysh(cmds.reduce([]){ |cmds, cmd| cmds << '-c' << cmd })

    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def rules
    @property_hash[:rules] || :absent
  end

  def rules=(value)
    destroy
    create unless value.empty?

    @property_hash[:rules] = value
  end
end
