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

          @event_generator = lambda { |time, finger, status|
            Events::Event.new(
              time: time,
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
                @event_generator.call(Time.now, 1, 'begin'),
                @event_generator.call(Time.now, 1, 'release')
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
                @event_generator.call(Time.now, 1, 'begin'),
                @event_generator.call(Time.now, 2, 'touch'),
                @event_generator.call(Time.now, 2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 2]
            end
          end

          context 'with 3 fingers tap events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,       1, 'begin'),
                @event_generator.call(time,       2, 'touch'),
                @event_generator.call(time,       3, 'touch'),
                @event_generator.call(time,       3, 'release'),
                @event_generator.call(time + 0.1, 2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 3]
            end
          end
          context 'with 4 fingers tap events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,       1, 'begin'),
                @event_generator.call(time,       2, 'touch'),
                @event_generator.call(time,       3, 'touch'),
                @event_generator.call(time,       4, 'touch'),
                @event_generator.call(time + 0.1, 4, 'end')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:tap, 4]
            end
          end

          context 'with 1 finger hold events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,     1, 'begin'),
                @event_generator.call(time + 2, 1, 'hold')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 1]
            end
          end

          context 'with 2 fingers hold events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,     1, 'begin'),
                @event_generator.call(time,     2, 'touch'),
                @event_generator.call(time,     2, 'hold'),
                @event_generator.call(time + 1, 2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate tap index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 2]
            end
          end
          context 'with 3 fingers hold events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,     1, 'begin'),
                @event_generator.call(time,     2, 'touch'),
                @event_generator.call(time,     3, 'hold'),
                @event_generator.call(time,     3, 'release'),
                @event_generator.call(time + 1, 2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate hold index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 3]
            end
          end
          context 'with 4 fingers hold events in buffer' do
            before do
              time = Time.now
              [
                @event_generator.call(time,     1, 'begin'),
                @event_generator.call(time,     2, 'touch'),
                @event_generator.call(time,     3, 'touch'),
                @event_generator.call(time,     4, 'touch'),
                @event_generator.call(time,     0, 'keep'),
                @event_generator.call(time,     0, 'keep'),
                @event_generator.call(time,     0, 'keep'),
                @event_generator.call(time + 1, 2, 'release')
              ].each { |event| @buffer.buffer(event) }
            end

            it 'should generate hold index' do
              key_symbol = @detector.detect([@buffer]).record.index.keys.map(&:symbol)
              expect(key_symbol).to eq [:hold, 4]
            end
          end
        end
      end
    end
  end
end
