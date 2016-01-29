require "spec_helper"

describe BLS_API::Retry do
  class Retrier
    include BLS_API::Retry
  end

  class ContrivedError < StandardError; end

  let(:retry_test_options) do
    {:max_retries => 4, :time_between_retries => 0.01}
  end

  describe "attempts a block" do
    it "once if successful" do
      retry_counter = double("Counter")
      allow(retry_counter).to receive(:attempt).and_return(0)

      expect(retry_counter).to receive(:attempt).once
      expect do
        Retrier.new.retry(retry_test_options) do
          retry_counter.attempt
        end
      end.not_to raise_error
    end

    it "multiple times if unsuccessful" do
      retry_counter = double("Counter")

      attempts_so_far = 0
      allow(retry_counter).to receive(:attempt) do
        attempts_so_far += 1
        raise StandardError unless attempts_so_far >= 2
      end

      expect(retry_counter).to receive(:attempt).twice
      expect do
        Retrier.new.retry(retry_test_options) do
          retry_counter.attempt
        end
      end.not_to raise_error
    end

    it "and raises the latest exception if all attempts fail" do
      retry_counter = double("Counter")

      allow(retry_counter).to receive(:attempt) { raise ContrivedError }

      expect(retry_counter).to receive(:attempt).exactly(5).times
      expect do
        Retrier.new.retry(retry_test_options) do
          retry_counter.attempt
        end
      end.to raise_error(ContrivedError)
    end
  end
end
