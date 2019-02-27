require "rspec"

require "financo"
require "financo/cli/program"
require "financo/cli/config"

Journal = Financo::Journal
AccountInfo = Financo::AccountInfo
Transaction = Financo::Transaction
Program = Financo::CLI::Program
Config = Financo::CLI::Config

describe Program do
  describe "version" do
    let(:stdout) { StringIO.new }
    let(:program) {
      Program.new(stdout: stdout, version: "1.0.1")
    }

    it "should print the version" do
      program.run(argv: %w[-v])

      expect(stdout.string).to eq "financo v1.0.1\n"
    end
  end

  describe "help" do
    let(:stdout) { StringIO.new }
    let(:program) { Program.new(stdout: stdout) }

    it "should print help when -h" do
      program.run(argv: %w[-h])

      exp = StringIO.open { |s|
        s.puts "usage: financo [options] <username> <password>"
        s.puts "    -v, --version                    print version"
        s.puts "    -h, --help                       print this help"
        s.string
      }
      expect(stdout.string).to eq exp
    end

    it "should print help when username and password are not provided" do
      program.run(argv: %w[])

      exp = StringIO.open { |s|
        s.puts "usage: financo [options] <username> <password>"
        s.puts "    -v, --version                    print version"
        s.puts "    -h, --help                       print this help"
        s.string
      }
      expect(stdout.string).to eq exp
    end
  end

  describe "credentials" do
    let(:program_opts) {
      {
        stdout: StringIO.new,
        account_info: ->(*) {},
        config_store: double("config_store"),
        account_transactions: ->(*) { [] },
      }
    }
    let(:program) { Program.new(program_opts) }

    before do
      # not relevant on this test suite
      allow(program_opts[:config_store])
        .to receive(:load).and_return(Config.new("1", "checking"))
      allow(program_opts[:config_store])
        .to receive(:save)
    end

    it "should call account_info" do
      expect(program_opts[:account_info])
        .to receive(:call)
        .and_call_original

      program.run(argv: %w[username password])
    end

    it "should show an error when invalid" do
      expect(program_opts[:account_info])
        .to receive(:call)
        .with("username", "password")
        .and_return(nil)

      program.run(argv: %w[username password])

      exp = StringIO.open { |s|
        s.puts "Invalid username or password"
        s.string
      }
      expect(program_opts[:stdout].string).to eq exp
    end

    it "should show a welcome message when valid" do
      expect(program_opts[:account_info])
        .to receive(:call)
        .with("username", "password")
        .and_return(AccountInfo.new("1", "Foobar"))

      program.run(argv: %w[username password])

      exp = StringIO.open { |s|
        s.puts "Welcome Foobar"
        s.puts "Nothing changed since last execution"
        s.string
      }
      expect(program_opts[:stdout].string).to eq exp
    end
  end

  describe "transactions" do
    let(:config) { Config.new("1", "checking", Time.now.to_i) }
    let(:program_opts) {
      {
        stdout: StringIO.new,
        account_info: double("account_info"),
        config_store: double("config_store"),
        account_transactions: double("account_transactions"),
      }
    }
    let(:program) { Program.new(program_opts) }

    before do
      # not relevant on this test suite
      allow(program_opts[:account_info])
        .to receive(:call)
        .and_return(AccountInfo.new(config.id, "Foobar"))
      allow(program_opts[:config_store])
        .to receive(:load).and_return(config)
      allow(program_opts[:config_store])
        .to receive(:save)
    end

    it "should call account_transactions" do
      expect(program_opts[:account_transactions])
        .to receive(:call)
        .with(config.id, config.loaded_at, config.retention_days)
        .and_return([])

      program.run(argv: %w[username password])
    end

    # it should set account attribute of transaction to config.checking value
  end

  describe "journal" do
    let(:transactions) {
      populate_transaction = ->(t) {
        t.date = Time.now.to_i * 1000
        t.description = "hello #{t.id}"
      }

      (0..4)
        .map { |i| Transaction.new(i) }
        .each(&populate_transaction)
    }
    let(:program_opts) {
      {
        stdout: StringIO.new,
        account_info: double("account_info"),
        config_store: double("config_store"),
        account_transactions: double("account_transactions"),
        journal: Journal.new(StringIO.new),
      }
    }
    let(:program) { Program.new(program_opts) }

    before do
      # not relevant on this test suite
      allow(program_opts[:account_info])
        .to receive(:call).and_return(AccountInfo.new("1", "Foobar"))
      allow(program_opts[:config_store])
        .to receive(:load).and_return(Config.new("1", "checking"))
      allow(program_opts[:config_store])
        .to receive(:save)
      allow(program_opts[:account_transactions])
        .to receive(:call).and_return(transactions)
    end

    it "should write transactions with status :added" do
      transactions[2].status = :added

      expect(program_opts[:journal])
        .to receive(:write)
        .with(transactions[2])
        .and_call_original

      program.run(argv: %w[username password])
    end

    it "should comment transactions with status :modified and :unknown" do
      transactions[1].status = :modified
      transactions[3].status = :unknown

      expect(program_opts[:journal])
        .to receive(:comment)
        .with(transactions[1])
        .and_call_original

      expect(program_opts[:journal])
        .to receive(:comment)
        .with(transactions[3])
        .and_call_original

      program.run(argv: %w[username password])
    end

    it "should ignore transactions with status nil or invalid" do
      transactions[0].status = nil
      transactions[1].status = :invalid
      transactions[4].status = :abc

      expect(program_opts[:journal])
        .to_not receive(:comment)
        .and_call_original

      expect(program_opts[:journal])
        .to_not receive(:comment)
        .and_call_original

      program.run(argv: %w[username password])
    end
  end

  describe "statistics" do
    let(:transactions) {
      populate_transaction = ->(t) {
        t.date = Time.now.to_i * 1000
        t.description = "hello #{t.id}"
      }

      (0..4)
        .map { |i| Transaction.new(i) }
        .each(&populate_transaction)
    }
    let(:program_opts) {
      {
        stdout: StringIO.new,
        account_info: double("account_info"),
        config_store: double("config_store"),
        account_transactions: double("account_transactions"),
        journal: Journal.new(StringIO.new),
      }
    }
    let(:program) { Program.new(program_opts) }

    before do
      # not relevant on this test suite
      allow(program_opts[:account_info])
        .to receive(:call).and_return(AccountInfo.new("1", "Foobar"))
      allow(program_opts[:config_store])
        .to receive(:load).and_return(Config.new("1", "checking"))
      allow(program_opts[:config_store])
        .to receive(:save)
      allow(program_opts[:account_transactions])
        .to receive(:call).and_return(transactions)
    end

    it "should show message when nothing changed" do
      program.run(argv: %w[username password])

      exp = StringIO.open { |s|
        s.puts "Welcome Foobar"
        s.puts "Nothing changed since last execution"
        s.string
      }
      expect(program_opts[:stdout].string).to eq exp
    end

    it "should show one message per transaction status type" do
      transactions[0].status = nil
      transactions[1].status = :added
      transactions[2].status = :modified
      transactions[3].status = :added
      transactions[4].status = :invalid

      program.run(argv: %w[username password])

      exp = StringIO.open { |s|
        s.puts "Welcome Foobar"
        s.puts "2 added transaction(s)"
        s.puts "1 modified transaction(s)"
        s.puts "1 invalid transaction(s)"
        s.string
      }
      expect(program_opts[:stdout].string).to eq exp
    end

    it "should calculate statistics based on transaction statuses" do
      transactions[0].status = nil
      transactions[1].status = :added
      transactions[2].status = :modified
      transactions[3].status = :added
      transactions[4].status = :invalid

      program.run(argv: %w[username password])

      expect(program.stats).to eq({added: 2, modified: 1, invalid: 1})
    end
  end
end
