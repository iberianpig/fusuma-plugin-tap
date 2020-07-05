# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/parsers/parser.rb'

module Fusuma
  module Plugin
    module Parsers
      RSpec.describe TapParser do
        describe '#parse_record' do
          before do
            version = ENV.fetch('LIBINPUT_VERSION', '1.14.1')

            @debug_log_version_dir = "spec/fusuma/plugin/parsers/#{version}"
            @parser = TapParser.new
          end
          context 'with 1 finger tap' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/1finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 1
              # expect(@records.map(&:status)).to eq %w[begin release end]
              expect(@records.map(&:status)).to be_include 'begin'
            end
          end
          context 'with 2 finger tap' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/2finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 2
              # expect(@records.map(&:status)).to eq %w[begin touch release end]
              expect(@records.map(&:status)).to be_include 'touch'
            end
          end

          context 'with 3 finger tap' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/3finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 3
              # expect(@records.map(&:status)).to eq %w[begin touch touch release release end]
              expect(@records.map(&:status)).to be_include 'touch'
            end
          end
          context 'with 4 finger tap' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/4finger-tap.txt").map do |line|
                @parser.parse_record(line)
                # finger, status
                # 1,      begin
                # 2,      touch
                # 3,      touch
                # 4,      touch
                # 0,      keep
                # 0,      keep
                # 4,      end
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 4
              expect(@records.map(&:status)).to be_include 'touch'
            end

            it 'should generate end record' do
              expect(@records.map(&:status)).to be_include 'end'
            end
          end

          context 'with 1 finger hold' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/1finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 1
              # expect(@records.map(&:status)).to eq %w[begin hold end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
          context 'with 2 finger hold' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/2finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 2
              # expect(@records.map(&:status)).to eq %w[begin touch hold release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
          context 'with 2 finger hold and scroll' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/2finger-hold-invalid.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 2
              # expect(@records.map(&:status)).to eq %w[begin touch hold release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
            it 'generate move record' do
              expect(@records.map(&:status)).to be_include 'move'
            end
          end
          context 'with 3 finger hold' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/3finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 3
              # expect(@records.map(&:status)).to eq %w[begin touch touch hold release release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
          context 'with 3 finger hold and scroll' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/3finger-hold-invalid.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 3
              # expect(@records.map(&:status)).to eq %w[begin touch hold release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
            it 'generate move record' do
              expect(@records.map(&:status)).not_to be_include 'move'
            end
          end
          context 'with 4 finger hold' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/4finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).to eq 4
              # Cannot detect 'HOLD' with 4 finger hold
              # it should be detect by holding time when existing 4 finger tap in buffer
              expect(@records.map(&:status)).not_to be_include 'hold'
            end
          end

          context 'with timeout' do
            before do
              line = 'LIBINPUT TIMEOUT'
              @record = @parser.parse_record(line)
            end

            it 'generate keep event' do
              expect(@record.status).to eq 'keep'
            end
          end

          context 'with 2 finger pinch and hold' do
            before do
              @records = File.readlines("#{@debug_log_version_dir}/2finger-pinch-and-hold-bug.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'should not generate 4 finger tap (bug)' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              expect(@records.map(&:finger).max).not_to eq 4
            end
          end
        end
      end
    end
  end
end
