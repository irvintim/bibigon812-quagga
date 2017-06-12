require 'spec_helper'

describe Puppet::Type.type(:quagga_bgp_network) do
  let(:quagga_bgp_network) do
    @provider_class = describe_class.provide(:quagga_bgp_network) {
      mk_resource_methods
    }
    @provider_class.stub(:suitable?).return true
    @provider_class
  end

  before :each do
    described_class.stubs(:defaultprovider).returns @provider_class
  end

  after :each do
    described_class.unprovide(:quagga_bgp_network)
  end

  it 'should have :name be its namevar' do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe "when validating attributes" do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end
  end

  describe 'when validating values' do
    describe 'ensure' do
      it 'should support present as a value' do
        expect { described_class.new(:name => '65000 192.168.1.0/24', :ensure => :present) }.to_not raise_error
      end

      it 'should support absent as a value' do
        expect { described_class.new(:name => '65000 192.168.1.0/24', :ensure => :absent) }.to_not raise_error
      end

      it 'should not support foo values' do
        expect { described_class.new(:name => '65000 192.168.1.0/24', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end
  end

  describe 'name' do
    it 'should support \'65000  192.168.1.0/24\' as a value' do
      expect { described_class.new(:name => '65000  192.168.1.0/24') }.to_not raise_error
    end

    it 'should support \'65000 192.168.1.0/24\' as a value' do
      expect { described_class.new(:name => '65000 192.168.1.1/32') }.to_not raise_error
    end

    it 'should support \'65000   2a04:6d40::/48\' as a value' do
      expect { described_class.new(:name => '65000   2a04:6d40::/48') }.to_not raise_error
    end

    it 'should not support \'65000 192.168.1.0\' as a value' do
      expect { described_class.new(:name => '65000,192.168.1.0') }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should not support \'192.168.1.0\' as a value' do
      expect { described_class.new(:name => '192.168.1.0/24') }.to raise_error(Puppet::Error, /Invalid value/)
    end
  end
end