require 'pstore'

module Bot
	module DiscordCommands
		module PstoreTest
			extend Discordrb::Commands::CommandContainer
			command :showstore do |event|
				store = PStore.new('db.pstore')
				entries = store.transaction { store.roots }
				entries.each do |msg|
					event.respond msg
				end
			end
		end
	end
end
