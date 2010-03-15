require 'spec_helper'

describe Money do

  before do
    @currency = mock('currency')
    @money = Money.new(10.5, @currency)
  end

  describe ".new" do
    it "should take two parameters: value and currency" do
      block_should_not(raise_error) { Money.new(10.50, mock('currency')) }
    end
  end

  describe "#value=" do
    context "when called with nil" do
      it do
        block_should(raise_error(ArgumentError)) { @money.value = nil }
      end
    end

    context "when called with number" do
      before { @money.value = 19.98 }

      it "should set the value" do
        @money.value.should == 19.98
      end
    end
  end

  describe "#currency=" do    
    context "when called with nil" do
      it do
        block_should(raise_error(ArgumentError)) { @money.currency = nil }
      end
    end

    context "when called with currency" do
      before { @money.currency = @currency = mock('currency') }

      it "should set the value" do
        @money.currency.should == @currency
      end
    end
  end

  describe "#to_s" do
    it "should return formatted value" do
      @currency.should_receive(:render).with(10.5).and_return('$10.50')
      @money.to_s.should == "$10.50"
    end
  end

  describe "#+" do
    context "when called with money of different currency" do
      it do
        block_should(raise_error(ArgumentError)) { @money + Money.new(3.03, mock('other currency')) }
      end
    end

    context "when called with money of the same currency" do
      before { @result = @money + Money.new(3.03, @currency) }

      describe "result" do
        it "should be of class Money" do
          @result.should be_instance_of(Money)
        end

        it "should be the sum of money" do
          @result.value.should == 13.53
          @result.currency.should == @currency
        end
      end
    end
  end

  describe "#*" do
    context "when called with sth different than Numeric instance" do
      it do
        block_should(raise_error(ArgumentError)) { @money * Money.new(3.03, mock('some currency')) }
      end
    end

    context "when called with Numeric instance" do
      before { @result = @money * 5 }

      describe "result" do
        it "should be of class Money" do
          @result.should be_instance_of(Money)
        end

        it "should be the sum of money" do
          @result.value.should == 52.50
          @result.currency.should == @currency
        end
      end
    end
  end

  describe "#<=>" do
    context "when called with money of different currency" do
      it do
        block_should(raise_error(ArgumentError)) { @money <=> Money.new(3.03, mock('other currency')) }
      end
    end

    context "when called with money of the same currency" do
      before { @result = @money <=> Money.new(3.03, @currency) }

      it "should compare values" do
        @result.should == 1
      end
    end
  end
end
