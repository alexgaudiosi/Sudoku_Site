require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application'
use Rack::Flash
set :partial_template_engine, :erb
set :session_secret, "I'm the secret key to sign the cookie"



enable :sessions

def random_sudoku
	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	sudoku = Sudoku.new(seed.join)
	sudoku.solve!
	sudoku.to_s.chars
end

def puzzle(sudoku)
	y = session[:difficulty]
	x = 0.15 if y = 3
	x = 0.45 if y = 2 
	x = 0.85 if y = 1
	 sudoku.map {|sudo| rand < x ? 0 : sudo  }
	end

get '/' do
	prepare_to_check_solution
	generate_new_puzzle_if_necessary
	@current_solution = session[:current_solution] || session[:puzzle]
	@solution = session[:solution]
	@puzzle = session[:puzzle]
	erb :index
end

get '/solution' do
 redirect to("/") if @check_solution == nil
  @current_solution = session[:solution]
	erb :index
end

post '/' do
  cells = (params["cell"])
  session[:current_solution] = box_order_to_row_order(cells)
  session[:check_solution] = true
  redirect to("/")
end

post '/restart' do
	session[:current_solution] = nil
	session[:difficulty] = params[:difficulty].to_i
	redirect to("/")
end

def box_order_to_row_order(cells)
	boxes = cells.each_slice(9).to_a
	(0..8).to_a.inject([]) {|memo, i|
		first_box_index = i / 3 * 3
		three_boxes = boxes[first_box_index, 3]
		three_rows_of_three = three_boxes.map do |box|
			row_number_in_a_box = i % 3
			first_cell_in_the_row_index = row_number_in_a_box * 3
			box[first_cell_in_the_row_index, 3]
		end
		memo += three_rows_of_three.flatten
	}
end

def generate_new_puzzle_if_necessary
	return if session[:current_solution]
	sudoku = random_sudoku
	session[:solution] = sudoku
	session[:puzzle] = puzzle(sudoku)
	session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
	@check_solution = session[:check_solution]
	if @check_solution
			flash[:notice] = "Incorrect values are highlighted in yellow"
		end
	session[:check_solution] = nil
end