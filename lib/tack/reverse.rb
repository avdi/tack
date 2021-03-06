module Tack

  class Reverse
    include Middleware
    
    def initialize(app)
      @app = app
    end

    def run_suite(tests)
      puts "--> Reversing order of tests"
      @app.run_suite(tests.reverse) 
    end

    private

  end

end
