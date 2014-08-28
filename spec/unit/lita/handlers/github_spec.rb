# -*- coding: UTF-8 -*-
#
# Copyright 2014 PagerDuty, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe Lita::Handlers::Github, lita_handler: true do
  let(:github) { Lita::Handlers::Forecast.new('robot') }

  it { routes_command('gh status').to(:gh_status) }
  it { routes_command('github status').to(:gh_status) }
  it { routes_command('gh version').to(:gh_version) }

  describe '#default_config' do
    it 'should disable repo_delete by default' do
      expect(Lita.config.handlers.github.repo_delete_enabled).to be_falsey
    end

    it 'should set repos to private by default' do
      expect(Lita.config.handlers.github.repo_private_default).to be_truthy
    end
  end

  describe '.gh_status' do
    context 'when GitHub status is good' do
      before do
        @octo = double(
          'Octokit::Client',
          github_status_last_message: {
            status: 'good', body: 'Everything is operating normally.',
            created_on: '1970-01-01 00:00:00 UTC'
          }
        )
        allow_any_instance_of(Lita::Handlers::Github).to receive(:octo).and_return(@octo)
      end

      it 'should return the current GitHub status' do
        send_command('gh status')
        expect(replies.last).to eql('GitHub is reporting that all systems are green!')
      end
    end

    context 'when GitHub status is minor' do
      before do
        @octo = double(
          'Octokit::Client',
          github_status_last_message: {
            status: 'minor', body: 'Minor issue',
            created_on: '1970-01-01 00:00:21 UTC'
          }
        )
        allow_any_instance_of(Lita::Handlers::Github).to receive(:octo).and_return(@octo)
      end

      it 'should return the current GitHub status' do
        send_command('gh status')
        expect(replies.last).to eql(
          "GitHub is reporting minor issues (status:yellow)! Last message:\n" \
            '1970-01-01 00:00:21 UTC :: Minor issue'
        )
      end
    end

    context 'when GitHub status is major' do
      before do
        @octo = double(
          'Octokit::Client',
          github_status_last_message: {
            status: 'major', body: 'Major issue',
            created_on: '1970-01-01 00:00:42 UTC'
          }
        )
        allow_any_instance_of(Lita::Handlers::Github).to receive(:octo).and_return(@octo)
      end

      it 'should return the current GitHub status' do
        send_command('gh status')
        expect(replies.last).to eql(
          "GitHub is reporting major issues (status:red)! Last message:\n" \
            '1970-01-01 00:00:42 UTC :: Major issue'
        )
      end
    end
  end

  describe '.gh_version' do
    it 'should send back the Lita version' do
      send_command('gh version')
      expect(replies.last).to eql "lita-github v#{LitaGithub::VERSION}"
    end
  end
end
