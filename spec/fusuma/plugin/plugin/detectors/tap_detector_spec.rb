# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/detectors/detector.rb'
require 'fusuma/plugin/buffers/gesture_buffer.rb'
require 'fusuma/plugin/events/event.rb'
require 'fusuma/config.rb'

module Fusuma
  module Plugin
    module Detectors
      RSpec.describe TapDetector do
        before do
          @detector = TapDetector.new
          @buffer = Buffers::GestureBuffer.new
        end

        describe '#detect' do
          context 'with tap event in buffer' do
            before do
              @buffer.clear
            end

            it { expect(@detector.detect([@buffer])).to eq nil }
          end

          context 'with not enough swipe events in buffer' do
            before do
              @buffer.clear
            end

            it { expect(@detector.detect([@buffer])).to eq nil }
          end
        end
      end
    end
  end
end
