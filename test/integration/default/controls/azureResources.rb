control 'azureResources' do

    title 'Azure Resources'
    desc 'Confirms Azure reeousces.'

    input('vm_name').each do | vm |
        describe azure_virtual_machine(resource_group: input('rg_name'), name: vm ) do
            it { should exist }
        end
    end

end