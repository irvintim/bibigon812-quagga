require 'spec_helper'

describe Puppet::Type.type(:quagga_system).provider(:quagga) do
  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end
  end

  describe 'prefetch' do
    it 'should have a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  context 'running-config' do
    before :each do
      described_class.expects(:vtysh).with(
        '-c', 'show running-config'
      ).returns '!
hostname router-1.sandbox.local
!
ip forwarding
ipv6 forwarding
!
ip multicast-routing
!
line vty
!
end'
    end

    it 'should return a resource' do
      expect(described_class.instances.size).to eq(1)
    end

    it 'should return the resource `quagga_system`' do
      expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq({
        :name => 'router-1.sandbox.local',
        :hostname => 'router-1.sandbox.local',
        :ip_forwarding => :true,
        :ipv6_forwarding => :true,
        :ip_multicast_routing => :true,
        :password => :absent,
        :enable_password => :absent,
        :line_vty => :true,
        :service_password_encryption => :false,
      })
    end
  end
end
