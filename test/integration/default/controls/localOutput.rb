control 'localOutput' do

    title 'Outputs test'
    desc 'Simple tests that the outputs are not empty'

    describe input('rg_name') do 
        it { should_not be_empty }
    end

    describe input('vm_public_ip') do
        it { should_not be_empty }
    end

    describe input('vm_name') do
        it { should_not be_empty }
    end

    describe input('vm_id') do
        it { should_not be_empty }
    end

end