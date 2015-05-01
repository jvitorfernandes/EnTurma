class ProvaBrasil < ActiveRecord::Base

	attr_accessor :prova_brasil_hash, :portuguese_average_score,
	:math_average_score


	def initialize(year, id_grade, id_state,final_year)
		@year = year
		@id_grade = id_grade
		@id_state = id_state
		#@final_year = final_year

		@final_year = final_year_avaiable( year, id_grade, id_state )

		request_prova_brasil_report
	end

	def final_year_avaiable( year, id_grade, id_state )

		final_year = ""
		#to use in the loop below , increments in one each loop
		id_grade_local = id_grade

		#will pick the last year avaiable and add 1
		local_final_year = ProvaBrasil.all.pluck(:year).max.to_i + 1

		#loop to test if the line in the table with the params year and id_grade are empty
		(year.to_i..local_final_year).each do |year_test|

			table_line = ProvaBrasil.where(:year => year_test,:id_grade => id_grade_local , :id_state => id_state)

			id_grade_local = id_grade_local.to_i + 1 #increments each loop
			
			#if table_line is empty, means that we have a final year to use
			if table_line.empty?

				final_year = (year_test - 1).to_s				
				break
			end
		end

		return final_year

	end


	def request_prova_brasil_report
		@prova_brasil_request_result = Array.new
		@math_score_result = Array.new
		@portuguese_score_result = Array.new
		#auxiliar variable to receive the given id_grade and make casts to the value.
		local_id_grade = @id_grade

		(@year..@final_year).each do |year|
			current_prova_brasil = request_prova_brasil(year,@id_state,local_id_grade)
			@math_score_result.push(current_prova_brasil.math_score)
			@portuguese_score_result.push(current_prova_brasil.portuguese_score)
			@prova_brasil_request_result.push(current_prova_brasil)

			#increments the id_grade through years.
			local_id_grade = (local_id_grade.to_i + 1).to_s

		end

		request_average_to_portuguese
		request_average_to_math
		request_standard_deviation_portuguese
		request_standard_deviation_math
		request_variance_portuguese
		request_variance_math

		@prova_brasil_hash = {:portuguese_score => @portuguese_score_result, 
		 :portguese_average => @portuguese_average_score,
		 :portuguese_standard_deviation => @standard_deviation_pt,
		 :portuguese_variance => @variance_pt,
		 :math_score => @math_score_result,
		 :math_average => @math_average_score,
		 :math_standard_deviation => @standard_deviation_math,
		 :math_variance => @variance_math
		 }
	end
	private :request_prova_brasil_report

	def request_average_to_portuguese
		@portuguese_average_score = compute_average_for(@portuguese_score_result)
	end
	private :request_average_to_portuguese

	def request_average_to_math
		@math_average_score = compute_average_for(@math_score_result)
	end
	private :request_average_to_math

	def request_standard_deviation_portuguese
		@standard_deviation_pt = compute_standard_deviation(@portuguese_score_result)
	end
	private :request_standard_deviation_portuguese

	def request_standard_deviation_math
		@standard_deviation_math = compute_standard_deviation(@math_score_result)
	end
	private :request_standard_deviation_math

	def request_variance_portuguese
		@variance_pt = compute_variance(@portuguese_score_result)
	end
	private :request_variance_portuguese

	def request_variance_math
		@variance_math = compute_variance(@math_score_result)
	end
	private :request_variance_math

	def compute_average_for(data)
		total_score = 0.0
		data.each do |current_data|
			total_score += current_data
		end
		return total_score/data.count
	end

	def compute_standard_deviation(data)
		average = compute_average_for(data)
		total_variance = 0.0
		data.each do |current_data|
			total_variance += (current_data - average)**2 
		end

		total_variance = total_variance/data.count
		standard_deviation 	= total_variance**(0.5)
		return standard_deviation

	end

	def compute_variance(data)
		average = compute_average_for(data)
		total_variance = 0.0
		data.each do |current_data|
			total_variance += (current_data - average)**2 
		end

		return total_variance
	end

	def request_prova_brasil(year, id_state, id_grade)
		return ProvaBrasil.where(:year => year,:id_grade => id_grade, :id_state => id_state).first
	end
	private :request_prova_brasil_report

end
