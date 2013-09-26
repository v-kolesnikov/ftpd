# encoding: utf-8

# Authour: Michael de Silva <michael@mwdesilva.com>
# CEO @ http://omakaselabs.com / Mentor @ http://railsphd.com
# https://twitter.com/bsodmike / https://github.com/bsodmike

# This is an example for using Ftpd as a means for spec driving
# interaction with a 'dummy' ftp server via RSpec.  In this example we
# assume the client is implemented via `Fetcher::FTPFetcher`.

require 'spec_helper'
require 'net/ftp'
require 'ftpd'
require 'tmpdir'

DATA_DIR = "#{Rails.root}/spec/documents"

class Driver
  def initialize(user, pwd, data_dir)
    @user = user
    @pwd = pwd
    @data_dir = data_dir
  end
  def authenticate(user, pwd); true; end
  def file_system(user); Ftpd::ReadOnlyDiskFileSystem.new(@data_dir); end
end

describe Fetcher::FTPFetcher do
  let(:server) do
    server = Ftpd::FtpServer.new Driver.new("spec_user", "spec_pwd", DATA_DIR)
    server.interface = "127.0.0.1"
    server.start
    puts "Server listening on port #{server.bound_port}"
    server
  end

  let(:subject) do
    Fetcher::FTPFetcher.new('lvh.me', 'u', 'p', '/ftp')
  end

  # NOTE In this example, the client implements `connect_and_list()`
  # where a connection is establishd and the files at the remote root
  # path are returned as an `Array`.
  describe "#connect_and_list" do
    it "should connect and not raise errors" do
      expect{subject.connect_and_list(server.bound_port)}.not_to raise_error
    end

    it "should connect to the FTP server and return an Array of files" do
      result = subject.connect_and_list(server.bound_port)
      expect(result).to be_a(Array)
      expect(result).not_to be_empty
    end
  end
end