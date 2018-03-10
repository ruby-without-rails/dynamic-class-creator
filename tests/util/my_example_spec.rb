require 'rspec'

describe 'My behaviour' do

  def method_test_one(*args)
    puts args.first.call(59)

    yield if block_given?
  end

  it 'should do something' do

    lamb = -> (x) {x *5}

    res = lamb.call(5)

    expect(res).to equal(25)

    method_test_one(lamb){puts lamb.call(229)}
  end
end