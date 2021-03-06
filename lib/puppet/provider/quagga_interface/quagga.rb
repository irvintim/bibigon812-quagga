Puppet::Type.type(:quagga_interface).provide :quagga do
  @doc = 'Manages quagga interface parameters'

  @resource_map = {
    :description => {
      :regexp => /\A\sdescription\s(.*)\Z/,
      :template => 'description<% unless value.nil? %> <%= value %><% end %>',
      :type => :string,
      :default => :absent
    },
    :ip_address => {
      :regexp => /\A\sip\saddress\s(.*)\Z/,
      :template => 'ip address <%= value %>',
      :type => :array,
      :default => [],
    },
    :bandwidth => {
      :regexp => /\A\sbandwidth\s(\d+)\Z/,
      :template => 'bandwidth<% unless value.nil? %> <%= value %><% end %>',
      :type => :fixnum,
      :default => :absent
    },
    :link_detect => {
      :regexp => /\A\slink-detect\Z/,
      :template => 'link-detect',
      :type => :boolean,
      :default => :false
    },
  }

  commands :vtysh => 'vtysh'

  def initialize(value)
    super(value)
    @property_flush = {}
  end

  def self.instances
    interfaces = []
    debug '[instances]'

    found_interface = false
    interface = {}

    config = vtysh('-c', 'show running-config')
    config.split(/\n/).collect do |line|
      # skip comments
      next if line =~ /\A!\Z/

      if line =~ /\Ainterface\s([\w\d\.]+)\Z/
        name = $1
        found_interface = true

        unless interface.empty?
          debug "interface: #{interface}"
          interfaces << new(interface)
        end

        interface = {
          :name => name,
          :ensure => :present,
          :enable => :true,
          :provider => self.name,
        }

        @resource_map.each do |property, options|
          if options[:type] == :array or options[:type] == :hash
            interface[property] = options[:default].clone
          else
            interface[property] = options[:default]
          end
        end
      elsif line =~ /\A\w/ and found_interface
        found_interface = false
      elsif found_interface
        @resource_map.each do |property, options|
          if line =~ /\A\sshutdown\Z/
            interface[:enable] = :false
          elsif line =~ options[:regexp]
            value = $1

            if value.nil?
              interface[property] = :true
            else
              case options[:type]
                when :array
                  interface[property] << value

                when :fixnum
                  interface[property] = value.to_i

                when :boolean
                  interface[property] = :true

                else
                  interface[property] = value

              end
            end

            break
          end
        end
      end
    end

    unless interface.empty?
      debug "interface: #{interface}"
      interfaces << new(interface)
    end

    interfaces
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
    debug '[create]'

    resource_map = self.class.instance_variable_get('@resource_map')

    cmds = []
    cmds << "configure terminal"
    cmds << "interface #{@resource[:name]}"

    resource_map.each do |property, options|
      if @resource[property] and ((resource[property].is_a?(Array) and !resource[property].empty?) or (@resource[property] != :absent))
        value = @resource[property]
        cmds << ERB.new(resource_map[property][:template]).result(binding)
      end
    end

    cmds << "end"
    cmds << "write memory"

    vtysh(cmds.reduce([]) { |cmds, cmd| cmds << '-c' << cmd })
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    debug '[destroy]'

    cmds = []
    cmds << "configure terminal"
    cmds << "interface #{@resource[:name]}"
    cmds << "shutdown"
    cmds << "exit"
    cmds << "no interface #{@resource[:name]}"
    cmds << "end"
    cmds << "write memory"

    vtysh(cmds.reduce([]) { |cmds, cmd| cmds << '-c' << cmd })
  end

  def enable
    debug '[enable]'

    cmds = []
    cmds << "configure terminal"
    cmds << "interface #{@resource[:name]}"
    cmds << "no shutdown"
    cmds << "end"
    cmds << "write memory"

    vtysh(cmds.reduce([]) { |cmds, cmd| cmds << '-c' << cmd })
    @property_hash[:enable] = :true
  end

  def disable
    debug '[disable]'

    cmds = []
    cmds << "configure terminal"
    cmds << "interface #{@resource[:name]}"
    cmds << "shutdown"
    cmds << "end"
    cmds << "write memory"

    vtysh(cmds.reduce([]) { |cmds, cmd| cmds << '-c' << cmd })
    @property_hash[:enable] = :false
  end

  def enabled?
    @property_hash[:enable]
  end

  def flush
    resource_map = self.class.instance_variable_get('@resource_map')
    name = @property_hash[:name].nil? ? @resource[:name] : @property_hash[:name]

    debug "[flush][#{name}]"

    cmds = []
    cmds << 'configure terminal'
    cmds << "interface #{name}"

    @property_flush.each do |property, v|
      if v == :false or v == :absent
        cmds << "no #{ERB.new(resource_map[property][:template]).result(binding)}"
      elsif v == :true and resource_map[property][:type] == :symbol
        cmds << "no #{ERB.new(resource_map[property][:template]).result(binding)}"
        cmds << ERB.new(resource_map[property][:template]).result(binding)
      elsif v == :true
        cmds << ERB.new(resource_map[property][:template]).result(binding)
      elsif resource_map[property][:type] == :array
        (@property_hash[property] - v).each do |value|
          cmds << "no #{ERB.new(resource_map[property][:template]).result(binding)}"
        end

        v.each do |value|
          cmds << ERB.new(resource_map[property][:template]).result(binding)
        end
      else
        value = v
        cmds << ERB.new(resource_map[property][:template]).result(binding)
      end

      @property_hash[property] = v
    end

    cmds << 'end'
    cmds << 'write memory'
    unless @property_flush.empty?
      vtysh(cmds.reduce([]){ |cmds, cmd| cmds << '-c' << cmd })
      @property_flush.clear
    end
  end

  @resource_map.keys.each do |property|
    define_method "#{property}" do
      @property_hash[property] || :absent
    end

    define_method "#{property}=" do |value|
      @property_flush[property] = value
    end
  end
end
