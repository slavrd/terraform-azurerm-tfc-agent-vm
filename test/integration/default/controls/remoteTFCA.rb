control 'remoteTFCA' do

    title 'TFCA installation'
    desc 'Confirms the the Terraform Cloud Agent is installed.'

    describe service('tfc-agent') do
        it { should be_installed }
    end

    tfca_token = input('input_tfca_pool_token')
    describe 'tfca-agent service configuration' do
        subject{ parse_config_file('/etc/systemd/system/tfc-agent.service', {multiple_values: true}) }

        it "should have Environment entry 'TFC_AGENT_TOKEN=#{tfca_token}'" do
            expect(subject.params['Service']['Environment']).to(include "TFC_AGENT_TOKEN=#{tfca_token}")
        end

    end

    input('var_tfca_env_vars').each do |key, value|

        describe 'tfca-agent service configuration' do
            subject{ parse_config_file('/etc/systemd/system/tfc-agent.service', {multiple_values: true}) }

            it "should have Environment entry '#{key}=#{value}'" do
                expect(subject.params['Service']['Environment']).to(include "#{key}=#{value}")
            end

        end

    end

end