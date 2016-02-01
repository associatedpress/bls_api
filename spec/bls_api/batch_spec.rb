require "spec_helper"

describe BLS_API::Batch do
  class Batcher
    include BLS_API::Batch
  end
  let(:batcher) { Batcher.new }

  describe ".batch" do
    it "batches series ID/year combos" do
      expected_batches = [
        {:series_ids => [0, 1, 2], :start_year => 1995, :end_year => 1998},
        {:series_ids => [0, 1, 2], :start_year => 1991, :end_year => 1994},
        {:series_ids => [0, 1, 2], :start_year => 1988, :end_year => 1990},
        {:series_ids => [3, 4, 5], :start_year => 1995, :end_year => 1998},
        {:series_ids => [3, 4, 5], :start_year => 1991, :end_year => 1994},
        {:series_ids => [3, 4, 5], :start_year => 1988, :end_year => 1990},
        {:series_ids => [6, 7, 8], :start_year => 1995, :end_year => 1998},
        {:series_ids => [6, 7, 8], :start_year => 1991, :end_year => 1994},
        {:series_ids => [6, 7, 8], :start_year => 1988, :end_year => 1990},
        {:series_ids => [9, 10], :start_year => 1995, :end_year => 1998},
        {:series_ids => [9, 10], :start_year => 1991, :end_year => 1994},
        {:series_ids => [9, 10], :start_year => 1988, :end_year => 1990}
      ]
      test_batches = batcher.batch(
        (0..10), 1988, 1998, :max_years => 4, :max_series => 3)

      expected_batches.zip(test_batches) do |expected_batch, test_batch|
        expect(test_batch).to eq(expected_batch)
        $stdout.write(".")
      end
    end
  end

  describe ".get_series_groups" do
    it "batches series IDs" do
      expected_groups = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [10, 11, 12, 13, 14, 15]
      ]
      test_groups = batcher.get_series_groups((0..15).to_a, 10)

      expect(test_groups).to eq(expected_groups)
    end
  end

  describe ".get_year_groups" do
    it "batches years" do
      expected_groups = [
        [2011, 2015],
        [2006, 2010],
        [2001, 2005],
        [1998, 2000]
      ]
      test_groups = batcher.get_year_groups(1998, 2015, 5)

      expect(test_groups).to eq(expected_groups)
    end
  end
end
