describe 'User script' do
  it 'should be executable' do
    File.executable?(File.join(File.dirname(__FILE__), '..', '..', 'bin', 'nezu')).should be_true
  end

  it 'should have a "new" option' do
    puts File.expand_path(File.dirname(__FILE__), '..', '..', 'bin', 'nezu')
  end
end
