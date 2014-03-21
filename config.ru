require './sudoku'
# require './helpers/application'
# require './app'

# use Rack::Static,
#   :urls => ["/images", "/js", "/css"],
#   :root => "public"

run Sinatra::Application
