module RSpec::PageRegression
  module Renderer

    def self.render(page, test_image_path)
      test_image_path.dirname.mkpath unless test_image_path.dirname.exist?

      width  = Capybara.current_session.driver.evaluate_script("window.innerWidth")
      height = Capybara.current_session.driver.evaluate_script("window.innerHeight")

      page.driver.save_screenshot test_image_path, width: width, height: height
    end
  end
end
