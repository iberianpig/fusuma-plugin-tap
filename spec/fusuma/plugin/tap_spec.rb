# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Fusuma::Plugin::Tap do
  it 'has a version number' do
    expect(Fusuma::Plugin::Tap::VERSION).not_to be nil
  end
end
