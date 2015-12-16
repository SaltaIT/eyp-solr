require 'spec_helper'
describe 'solr' do

  context 'with defaults for all parameters' do
    it { should contain_class('solr') }
  end
end
