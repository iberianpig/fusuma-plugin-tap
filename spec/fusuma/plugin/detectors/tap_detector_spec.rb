# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/detectors/detector.rb'
require 'fusuma/plugin/buffers/gesture_buffer.rb'
require 'fusuma/plugin/events/event.rb'

module Fusuma
  module Plugin
    module Detectors
      RSpec.describe TapDetector do
        before do
          @detector = TapDetector.new
          @buffer = Buffers::TapBuffer.new

          @event_generator = lambda { |finger, status|
            Events::Event.new(
              tag: 'libinput_tap_parser',
              record: Events::Records::GestureRecord.new(
                finger: finger,
                gesture: 'tap',
                status: status,
                direction: Events::Records::GestureRecord::Delta.new(0, 0, 0, 0)
              )
            )
          }
        end

        describe '#detect' do
          context 'with 1 finger tap events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(1, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 1]
            end
          end

          context 'with 2 fingers tap events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(2, 'touch'),
                @event_generator.call(2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 2]
            end
          end

          context 'with 2 fingers tap events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(2, 'touch'),
                @event_generator.call(3, 'touch'),
                @event_generator.call(3, 'release'),
                @event_generator.call(2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 3]
            end
          end

          context 'with 1 finger hold events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(1, 'hold')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 1]
            end
          end

          context 'with 2 fingers hold events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(2, 'touch'),
                @event_generator.call(2, 'hold'),
                @event_generator.call(2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 2]
            end
          end
          context 'with 3 fingers hold events in buffer' do
            before do
              [
                @event_generator.call(1, 'begin'),
                @event_generator.call(2, 'touch'),
                @event_generator.call(3, 'hold'),
                @event_generator.call(3, 'release'),
                @event_generator.call(2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 3]
            end
          end
        end
      end
    end
  end
end
