# frozen_string_literal: true

require 'test_helper'

class ClientErrorTest < Minitest::Test
  def test_response_attr
    response = Struct.new(:uri, :code, :body).new

    error = Financo::N26::Client::ClientError.new(response)

    assert_same(response, error.response)
  end

  def test_message
    response = Struct.new(:uri, :code, :body)
      .new(URI('https://www.google.com'), '200', 'OK')

    error = Financo::N26::Client::ClientError.new(response)

    assert_equal('https://www.google.com > 200 > OK', error.message)
  end

  def test_from_response_bad_request
    response = Struct.new(:uri, :code, :body)
      .new(URI('https://www.google.com'), '400', 'Bad Request')

    error = Financo::N26::Client::ClientError.from_response(response)

    assert_instance_of(Financo::N26::Client::BadRequestError, error)
  end

  def test_from_response_unauthorized
    response = Struct.new(:uri, :code, :body)
      .new(URI('https://www.google.com'), '401', 'Bad Request')

    error = Financo::N26::Client::ClientError.from_response(response)

    assert_instance_of(Financo::N26::Client::UnauthorizedError, error)
  end

  def test_from_response_other
    response = Struct.new(:uri, :code, :body)
      .new(URI('https://www.google.com'), '402', 'Payment Required')

    error = Financo::N26::Client::ClientError.from_response(response)

    assert_instance_of(Financo::N26::Client::ClientError, error)
  end
end
