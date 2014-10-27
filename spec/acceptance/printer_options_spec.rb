require 'spec_helper_acceptance'

describe 'printer resource options parameter' do

  describe '(issue #38) when setting auth-info-required, the option isnt modified.' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_set_authinfo':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'Generic Test AuthInfo',
          options      => {
            'auth-info-required' => 'negotiate'
          }
       }
      EOS
    }

    it 'should complete with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
    end

    it 'should display auth-info-required=negotiate as part of the options listing' do
      expect(shell("lpoptions -p cups_printer_set_authinfo").stdout).to include("auth-info-required=negotiate")
    end
  end

  describe '(issue #38) when setting auth-info-required=none, the puppet run is not idempotent.' do
    let(:manifest) {
      <<-EOS
       printer { 'cups_printer_no_authinfo':
          ensure       => present,
          model        => 'drv:///sample.drv/deskjet.ppd',
          description  => 'Generic Test AuthInfo None',
          options      => {
            'auth-info-required' => 'none'
          }
       }
      EOS
    }

    it 'should complete with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      expect(apply_manifest(manifest, :catch_failures => true).exit_code).to be_zero
    end

    it 'should not include auth-info-required as part of the options listing' do
      expect(shell("lpoptions -p cups_printer_no_authinfo").stdout).to_not include("auth-info-required")
    end
  end

  after(:all) do
    # Clean up tests for re-run
    shell("lpadmin -x cups_printer_set_authinfo")
    shell("lpadmin -x cups_printer_no_authinfo")
  end

end