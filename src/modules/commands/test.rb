module Bot
  module DiscordCommands
    module Test
    	extend Discordrb::Commands::CommandContainer

    	command :test do |event, name, age|
    		event.respond "#{name}#{age}"
    	end
    end
  end
end