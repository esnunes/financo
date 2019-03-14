require "test_helper"

class HistoryTest < Minitest::Test
  def test_add_new_entry
    history = Financo::N26::History.new

    status = history.add("1", Time.now.to_i, 123.45)

    assert_equal(:added, status)
  end

  def test_add_new_entry_with_old_date
    now = Time.now.to_i
    history = Financo::N26::History.new(entries: [], loaded_at: now)

    status = history.add("1", now - 10, 123.45)

    assert_equal(:unknown, status)
  end

  def test_add_existing_entry_with_same_data
    entries = [ { "id" => "1", "date" => 0, "amount" => 10 } ]
    history = Financo::N26::History.new(entries: entries)

    status = history.add("1", 0, 10)

    assert_nil(status)
  end

  def test_add_existing_entry_with_new_data
    entries = [ { "id" => "1", "date" => 0, "amount" => 10 } ]
    history = Financo::N26::History.new(entries: entries)

    status = history.add("1", 0, 20)

    assert_equal(:modified, status)
  end

  def test_dump
    entries = [ { "id" => "1", "date" => 20, "amount" => 10 } ]
    history = Financo::N26::History.new(entries: entries, loaded_at: 10)

    history.add("2", 30, 123.45)
    dump = history.dump

    exp = StringIO.open do |s|
      s.puts "---"
      s.puts "entries:"
      s.puts "- id: '1'"
      s.puts "  date: 20"
      s.puts "  amount: 10"
      s.puts "- id: '2'"
      s.puts "  date: 30"
      s.puts "  amount: 123.45"
      s.puts "loaded_at: 10"
      s.string
    end
    assert_equal(exp, dump)
  end
end
