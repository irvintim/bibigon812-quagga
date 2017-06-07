require 'spec_helper'

describe Puppet::Type.type(:bgp) do
  let(:networking_service) do
    @provider_class = describe_class.provide(:bgp) {
      mk_resource_methods
    }
    @provider_class.stub(:suitable?).return true
    @provider_class
  end

  before :each do
    described_class.stubs(:defaultprovider).returns @provider_class
  end

  after :each do
    described_class.unprovide(:bgp)
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

    [:ipv4_unicast, :maximum_paths_ebgp, :maximum_paths_ibgp, :router_id].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe 'when validating values' do
    describe 'ensure' do
      it 'should support present as a value' do
        expect { described_class.new(:name => '197888', :ensure => :present) }.to_not raise_error
      end

      it 'should support absent as a value' do
        expect { described_class.new(:name => '197888', :ensure => :absent) }.to_not raise_error
      end

      it 'should not support other values' do
        expect { described_class.new(:name => '197888', :ensure => :foo) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end
  end

  describe 'name' do
    it 'should support as100 as a value' do
      expect { described_class.new(:name => '197888') }.to_not raise_error
    end

    it 'should support 197888 as a value' do
      expect { described_class.new(:name => '197888') }.to_not raise_error
    end

    it 'should not support AS197888 as a value' do
      expect { described_class.new(:name => 'AS197888') }.to raise_error(Puppet::Error, /Invalid value/)
    end
  end

  [:import_check, :ipv4_unicast].each do |property|
    describe "boolean values of the property `#{property}`" do
      it 'should support \'true\' as a value' do
        expect { described_class.new(:name => '65000', property => 'true') }.to_not raise_error
      end

      it 'should support :true as a value' do
        expect { described_class.new(:name => '65000', property => :true) }.to_not raise_error
      end

      it 'should support true as a value' do
        expect { described_class.new(:name => '65000', property => true) }.to_not raise_error
      end

      it 'should support \'false\' as a value' do
        expect { described_class.new(:name => '65000', property => 'false') }.to_not raise_error
      end

      it 'should support :false as a value' do
        expect { described_class.new(:name => '65000', property => :false) }.to_not raise_error
      end

      it 'should support false as a value' do
        expect { described_class.new(:name => '65000', property => false) }.to_not raise_error
      end

      it 'should not support :enabled as a value' do
        expect { described_class.new(:name => '65000', property => :enabled) }.to raise_error(Puppet::Error, /Invalid value/)
      end

      it 'should not support \'disabled\' as a value' do
        expect { described_class.new(:name => '65000', property => 'disabled') }.to raise_error(Puppet::Error, /Invalid value/)
      end

      it 'should contain :true' do
        expect(described_class.new(:name => '65000', property => 'true')[property]).to eq(:true)
      end

      it 'should contain :true' do
        expect(described_class.new(:name => '65000', property => true)[property]).to eq(:true)
      end

      it 'should contain :false' do
        expect(described_class.new(:name => '65000', property => 'false')[property]).to eq(:false)
      end

      it 'should contain :false' do
        expect(described_class.new(:name => '65000', property => false)[property]).to eq(:false)
      end
    end
  end

  describe 'maximum_paths_ebgp' do
    it 'should support 5 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ebgp => '5') }.to_not raise_error
    end

    it 'should support 5 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ebgp => 5) }.to_not raise_error
    end

    it 'should not support 0 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ebgp => '0') }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should not support 70 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ebgp => 70) }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should contain 5' do
      expect(described_class.new(:name => '197888', :maximum_paths_ebgp => '5')[:maximum_paths_ebgp]).to eq(5)
    end

    it 'should contain 8' do
      expect(described_class.new(:name => '197888', :maximum_paths_ebgp => 8)[:maximum_paths_ebgp]).to eq(8)
    end
  end

  describe 'maximum_paths_ibgp' do
    it 'should support 5 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ibgp => '5') }.to_not raise_error
    end

    it 'should support 5 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ibgp => 5) }.to_not raise_error
    end

    it 'should not support 0 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ibgp => '0') }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should not support 70 as a value' do
      expect { described_class.new(:name => '197888', :maximum_paths_ibgp => 70) }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should contain 5' do
      expect(described_class.new(:name => '197888', :maximum_paths_ibgp => '5')[:maximum_paths_ibgp]).to eq(5)
    end

    it 'should contain 8' do
      expect(described_class.new(:name => '197888', :maximum_paths_ibgp => 8)[:maximum_paths_ibgp]).to eq(8)
    end
  end

  describe 'router_id' do
    it 'should support 192.168.1.1 as a value' do
      expect { described_class.new(:name => '197888', :router_id => '192.168.1.1') }.to_not raise_error
    end

    it 'should not support 256.1.1.1 as a value' do
      expect { described_class.new(:name => '197888', :router_id => '256.1.1.1') }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should not support 1.-1.1.1 as a value' do
      expect { described_class.new(:name => '197888', :router_id => '1.-1.1.1') }.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should contain 192.168.1.1' do
      expect(described_class.new(:name => '197888', :router_id => '192.168.1.1')[:router_id]).to eq('192.168.1.1')
    end

    it 'should contain 1.1.1.1' do
      expect(described_class.new(:name => '197888', :router_id => '1.1.1.1')[:router_id]).to eq('1.1.1.1')
    end
  end
end