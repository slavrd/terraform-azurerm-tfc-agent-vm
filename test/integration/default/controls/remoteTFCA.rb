control 'remoteTFCA' do

    title 'TFCA installation'
    desc 'Confirms the the Terraform Cloud Agent is installed.'

    describe service('tfc-agent') do
        it { should be_installed }
    end

    input('var_tfca_env_vars').each do |key, value|
        describe 'tfca-agent configuration' do
            subject{ parse_config_file('/etc/systemd/system/tfc-agent.service', {multiple_values: true}) }
            it "should have Environment entriy '#{key}=#{value}'" do
                expect(subject.params['Service']['Environment']).to(include "#{key}=#{value}")
            end
        end
    end

end