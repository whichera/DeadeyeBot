module Bot
	module DiscordCommands
		module Match
			class Week
				def initialize(week_number)
					@week_number = week_number
					@week = "w#{@week_number}"
				end

				def getinfo
			    if defined?(@week)
			      if data[@week.to_sym].is_a?(Array)
			        $response = "Week #{@week_number} maps are: #{data[@week.to_sym].map {|map| map.to_s }.join(', ')}."
			      else
			        $response = "Week #{@week_number} #{data[@week.to_sym]}."
			      end
			    else
			      $response = "Check your week number mate."
			    end
			  end

			  def defined?(week)
			    if data[week.to_sym].present?
			      return true
			    else
			      return false
			    end
			  end

				private

				def data
					{
						w5: ["Nepal", "Watchpoint Gibraltar", "Temple of Anubis", "Oasis"],
						w6: ["Nepal", "King's Row", "Lijiang Tower"],
						w7: ["Nepal", "King's Row", "Volskaya Industries"],
						w8: "we get a BYE",
						w9: ["Nepal", "Temple of Anubis", "Route 66"],
						w10: "is TBA: 2nd and 3rd Place BO5 Match"
					}
				end
			end
			
			extend Discordrb::Commands::CommandContainer
			command :week do |event, n|
				Week.new(n).getinfo
				event.respond "#{$response}"
			end
		end
	end
end