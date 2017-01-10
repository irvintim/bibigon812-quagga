Puppet::Type.newtype(:ospf_interface) do
  @doc = %q{This type provides the capabilites to manage ospf parameters of
    network interfaces within puppet.}

  ensurable

  newparam(:name) do
    desc %q{The friendly name of the network interface.}
  end

  newproperty(:cost) do
    desc %q{Interface cost.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 1 or value > 65535
        raise ArgumentError, 'Cost: 1-65535'
      end
    end

    munge do |value|
      value.to_i
    end
  end

  newproperty(:dead_interval) do
    desc %q{Interval after which a neighbor is declared dead.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 1 or value >  65535
        raise ArgumentError, 'Interval after which a neighbor is declared dead: 1-65535 seconds'
      end
    end

    munge do |value|
      value.to_i
    end
  end

  newproperty(:hello_interval) do
    desc %q{Time between HELLO packets.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 1 or value > 65535
        raise ArgumentError, 'Time between HELLO packets: 1-65535 seconds'
      end
    end

    munge do |value|
      value.to_i
    end
  end

  newproperty(:mtu_ignore) do
    desc %q{Disable mtu mismatch detection.}

    newvalues(:true, :false)
    defaultto(:false)

    munge do |value|
      value.to_s.to_sym
    end
  end

  newproperty(:network_type) do
    desc %q{Network type.}

    newvalues(:broadcast, :non_broadcast, :point_to_multipoint, :point_to_point)
    newvalues('non-broadcast', 'point-to-multipoint', 'point-to-point')

    munge do |value|
      value.to_s.gsub(/-/, '_').to_sym
    end
  end

  newproperty(:priority) do
    desc %q{Router priority.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 0 or value > 255
        raise ArgumentError, 'Priority: 0-255'
      end
    end

    munge do |value|
      value.to_i
    end
  end

  newproperty(:retransmit_interval) do
    desc %q{Time between retransmitting lost link state advertisements.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 3 or value > 65535
        raise ArgumentError, 'Time between retransmitting lost link state advertisements: 3-65535 seconds'
      end
    end

    munge do |value|
      value.to_i
    end
  end

  newproperty(:transmit_delay) do
    desc %q{Link state transmit delay.}

    newvalues(/\A\d+\Z/)

    validate do |value|
      value = value.to_i
      if value < 1 or value > 65535
        raise ArgumentError, 'Link state transmit delay: 1-65535 seconds'
      end
    end

    munge do |value|
      value.to_i
    end
  end
end