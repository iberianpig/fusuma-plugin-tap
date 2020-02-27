# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Fusuma::Plugin::Tap do
  it 'has a version number' do
    expect(Fusuma::Plugin::Tap::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
