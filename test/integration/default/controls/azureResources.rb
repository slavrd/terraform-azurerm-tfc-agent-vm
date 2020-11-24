control 'azureResources' do

    title 'Azure Resources'
    desc 'Confirms Azure reeousces.'

    describe azure_virtual_machine(resource_group: input('rg_name'), name: input('vm_name') ) do
        it { should exist }
    end

end