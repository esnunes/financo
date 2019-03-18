# frozen_string_literal: true

require 'test_helper'

class HistoryStoreTest < Minitest::Test
  def test_create_base_dir
    Dir.mktmpdir do |tmp_dir|
      base_dir = File.join(tmp_dir, 'test_create_base_dir')

      Financo::N26::HistoryStore.new(base_dir: base_dir)

      assert(Dir.exist?(base_dir))
      assert(
        File.stat(base_dir).mode.to_s(8).end_with?('700'),
        'Expected directory mode to be 0o700'
      )
    end
  end

  def test_load_creates_history_file_when_not_found
    Dir.mktmpdir do |tmp_dir|
      base_dir = File.join(tmp_dir, '.financo')
      history_store = Financo::N26::HistoryStore.new(base_dir: base_dir)

      history_store.load('123')

      assert(File.exist?(File.join(base_dir, 'history-123.yaml')))
    end
  end

  def test_load_existing_history_file
    Dir.mktmpdir do |tmp_dir|
      base_dir = File.join(tmp_dir, '.financo')
      history_store = Financo::N26::HistoryStore.new(base_dir: base_dir)
      File.open(File.join(base_dir, 'history-123.yaml'), 'w') do |f|
        f.puts '---'
        f.puts 'loaded_at: 12345'
      end

      history = history_store.load('123')

      assert_equal(12345, history.loaded_at)
    end
  end

  def test_save_modified_history
    Dir.mktmpdir do |tmp_dir|
      base_dir = File.join(tmp_dir, '.financo')
      history_store = Financo::N26::HistoryStore.new(base_dir: base_dir)
      history = history_store.load('123')
      history.loaded_at = 12345

      history_store.save('123', history)

      exp = StringIO.open do |s|
        s.puts '---'
        s.puts 'entries: []'
        s.puts 'loaded_at: 12345'
        s.string
      end
      assert_equal(
        exp,
        File.read(File.join(base_dir, 'history-123.yaml'))
      )
    end
  end
end
