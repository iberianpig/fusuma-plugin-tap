# frozen_string_literal: true

require 'spec_helper'

require 'fusuma/plugin/parsers/parser.rb'

module Fusuma
  module Plugin
    module Parsers
      RSpec.describe TapParser do
        describe '#parse_record' do
          before do
            version = ENV.fetch('SPEC_LIBINPUT_VERSION', '1.14.1')

            @log_dir = "spec/fusuma/plugin/parsers/#{version}"
            @parser = TapParser.new
          end
          context 'with 1 finger tap' do
            before do
              @records = File.readlines("#{@log_dir}/1finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin release end]
              expect(@records.map(&:status)).to be_include 'begin'
            end
          end
          context 'with 2 finger tap' do
            before do
              @records = File.readlines("#{@log_dir}/2finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin touch release end]
              expect(@records.map(&:status)).to be_include 'touch'
            end
          end

          context 'with 3 finger tap' do
            before do
              @records = File.readlines("#{@log_dir}/3finger-tap.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate tap record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin touch touch release release end]
              expect(@records.map(&:status)).to be_include 'touch'
            end
          end

          context 'with 1 finger hold' do
            before do
              @records = File.readlines("#{@log_dir}/1finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin hold end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
          context 'with 2 finger hold' do
            before do
              @records = File.readlines("#{@log_dir}/2finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin touch hold release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
          context 'with 3 finger hold' do
            before do
              @records = File.readlines("#{@log_dir}/3finger-hold.txt").map do |line|
                @parser.parse_record(line)
              end.compact
            end
            it 'generate hold record' do
              expect(@records.map(&:gesture)).to all(eq 'tap')
              # expect(@records.map(&:status)).to eq %w[begin touch touch hold release release end]
              expect(@records.map(&:status)).to be_include 'hold'
            end
          end
        end
      end
    end
  end
end