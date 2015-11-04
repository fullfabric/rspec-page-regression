require "open3"
require "image_size"

module RSpec::PageRegression
  class ImagickComparison
    attr_reader :result

    def initialize(filepaths, metadata, opts={})
      @filepaths = filepaths
      @equipment = metadata[:equipment]
      @orientation = metadata[:orientation]
      @resolution = metadata[:resolution]
      @opts = opts

      @result = compare
    end

    def expected_size
      [@iexpected.width , @iexpected.height]
    end

    def test_size
      [@itest.width , @itest.height]
    end

    private

    def percentage(img_size, px_value)
      pixel_count = (px_value / img_size) * 100
      pixel_count.round(2)
    end

    def fuzz
      read_opt(:fuzz, RSpec::PageRegression.fuzz)
    end

    def threshold
      read_opt(:threshold, RSpec::PageRegression.threshold)
    end

    def compare
      @filepaths.difference_image.unlink if @filepaths.difference_image.exist?

      return :missing_expected unless @filepaths.expected_image.exist?
      return :missing_test unless @filepaths.test_image.exist?

      cmdline = "compare -dissimilarity-threshold 1 -fuzz #{fuzz}% -metric AE -highlight-color blue #{@filepaths.expected_image} #{@filepaths.test_image} #{@filepaths.difference_image}"
      px_value = Open3.popen3(cmdline) { |_stdin, _stdout, stderr, _wait_thr| stderr.read }.to_f

      begin
        img_size = ImageSize.path(@filepaths.difference_image).size.inject(:*)
        relative_difference = percentage(img_size, px_value)

        return :match if threshold >= relative_difference
        return :difference
      rescue
        return :difference
      end
    end

    def numeric(value)
      value.is_a?(Numeric) ? value : nil
    end

    def read_opt(opt, default)
      equipment   = @equipment.to_sym
      orientation = @orientation.to_sym

      numeric(@opts[opt]) ||
      numeric(@opts[opt].try(:[], equipment)) ||
      numeric(@opts[opt].try(:[], equipment).try(:[], orientation)) ||
      default
    end
  end
end
