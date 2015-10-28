require 'active_support/core_ext/string/inflections'

module RSpec
  module PageRegression
    module Cucumber
      class FilePaths
        attr_reader :expected_image
        attr_reader :test_image
        attr_reader :difference_image

        def initialize(scenario, expected_path = nil)
          expected_path = Pathname.new(expected_path) if expected_path
          canonical_path = Pathname.new("#{File.basename(scenario.feature_file)}_#{scenario.feature_name}".parameterize('_'))

          app_root = ::Rails.root
          expected_root = app_root + "spec" + "expectation"
          test_root = app_root + "tmp" + "spec" + "expectation"
          cwd = Pathname.getwd

          @expected_image = expected_path || (expected_root + canonical_path + "expected.png").relative_path_from(cwd)
          @test_image = (test_root + canonical_path + "test.png").relative_path_from cwd
          @difference_image = (test_root + canonical_path + "difference.png").relative_path_from cwd
        end

        def all
          [test_image, expected_image, difference_image]
        end
      end
    end
  end
end
