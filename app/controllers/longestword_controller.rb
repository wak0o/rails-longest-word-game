class LongestwordController < ApplicationController
 require 'open-uri'
 require 'json'
 require 'time'

 KEY = 'fb27f491-aea6-49b7-8508-025e689c3978'
 URL = 'https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key='

  def game
    # Build the grid
    @grid = generate_grid(13).join(' ')
    @start_time = Time.now
  end

  def score
    # Retrieve all game data from form
    grid = params[:grid].split("")
    @attempt = params[:attempt]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    # Compute score
    @result = run_game(@attempt, grid, start_time, end_time)
  end

  private

  def run_game(attempt, grid, start_time, end_time)
    result = {}
    result[:time] = (end_time - start_time).to_i
    case_analyze(attempt, result, grid)
    result
  end

  def case_analyze(attempt, result, grid)
    if !check_grid(attempt, grid)
      result[:score] = 0
      result[:message] = 'Not in the grid !'
    elsif check_word(attempt) == attempt
      result[:score] = 0
      result[:message] = 'Not an english word !'
    else
      result[:translation] = check_word(attempt)
      result[:score] = (attempt.length * 100 / result[:time].to_f).round(2)
      p result[:score] #/
      result[:message] = 'Well done !'
    end
    result
  end

  def generate_grid(grid_size)
    grid = []
    grid_size.times { grid << ('A'..'Z').to_a.sample }
    grid
  end

  def check_grid(attempt, grid)
    attempt_h = check_occurence(attempt.upcase.chars)
    grid_h = check_occurence(grid)
    attempt_h.each do |key, value|
      return false unless grid_h.key?(key)
      return false if value > grid_h[key]
    end
    true
  end

  def check_occurence(chars)
    hash = {}
    chars.each do |char|
      hash.key?(char) ? hash[char] += 1 : hash[char] = 1
    end
    hash
  end

  def check_word(attempt)
    JSON.parse(open(URL + KEY + '&input=' + attempt).read)["outputs"][0]["output"]
  end

end
