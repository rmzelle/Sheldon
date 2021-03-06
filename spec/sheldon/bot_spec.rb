require File.expand_path('../../spec_helper', __FILE__)

module Sheldon
  describe Bot do
    before do
      stub_request :any, /api\.github\.com/
    end

    it 'is ok' do
      get '/status'
      last_response.body.must_equal 'OK'
    end

    it 'is versioned' do
      get '/version'
      last_response.body.must_equal Sheldon::VERSION
    end

    describe '/pull_request' do
      it 'accepts only github hookshots' do
        post '/pull_request'
        last_response.status.must_equal 400
      end

      it 'accepts pull requests' do
        hookshot '/pull_request', :pull_request
        last_response.status.must_equal 202
      end

      it 'comments on opened pull requests' do
        hookshot '/pull_request', :pull_request, :pull_request_opened
        last_response.status.must_equal 201
      end

      it 'accepts pings' do
        hookshot '/pull_request', :ping
        last_response.status.must_equal 202
      end

      it 'does not accept other hookshots' do
        hookshot '/pull_request'
        last_response.status.must_equal 400
      end
    end

    describe '/build' do
      it 'accepts valid notifications' do
        travis_notify '/build', status: 'passed', type: 'pull_request'
        last_response.status.must_equal 201
      end

      it 'ignores notifications unless for pull requests' do
        travis_notify '/build'
        last_response.status.must_equal 202
      end

      it 'rejects other notifications' do
        travis_notify '/build', {}, 'foo'
        last_response.status.must_equal 400
      end
    end
  end
end
