require File.expand_path('../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../bin/metrics-springboot', File.dirname(__FILE__))

require 'webmock/rspec'

describe 'Spring Boot Metrics Script' do
  subject(:check_instance) { SpringBootMetrics.new(script_args) }
  let(:script_args) { [] }
  let(:expected_url) { 'http://localhost:8080/metrics' }

  before(:each) do
    mock_result_methods(check_instance)
    stub_request(:get, expected_url).to_return(body: '{"stat1":"val1"}')
  end

  context 'With no conifg' do
    it 'Should connect to http://localhost:8080/metrics' do
      check_instance.run

      expect(check_instance).to have_received(:ok)
      expect(check_instance).to have_received(:output).with("#{Socket.gethostname}.springboot_metrics.stat1", 'val1')
    end
  end

  context 'With full url' do
    let(:expected_url) { 'http://example.com/metrics' }
    let(:script_args) do
      ['--url', expected_url]
    end
    it 'Should use the url config' do
      check_instance.run

      expect(check_instance).to have_received(:ok)
    end
  end

  context 'With url parts' do
    let(:expected_url) { 'http://server:8888/path' }
    let(:script_args) do
      [
        '--protocol', 'http',
        '--path', '/path',
        '--port', '8888',
        '--host', 'server'
      ]
    end
    it 'Should build the url from the parts config' do
      check_instance.run

      expect(check_instance).to have_received(:ok)
    end
  end

  context 'When using ssl' do
    let(:expected_url) { 'https://example.com/metrics' }
    let(:script_args) do
      ['--url', expected_url]
    end

    it 'Should use https url' do
      check_instance.run

      expect(check_instance).to have_received(:ok)
    end
  end

  def mock_result_methods(instance)
    allow(instance).to receive(:critical)
    allow(instance).to receive(:warning)
    allow(instance).to receive(:ok)

    allow(instance).to receive(:output)
  end
end
