require 'pstore'

module Bot
	module DiscordCommands
		module PstoreTest
			extend Discordrb::Commands::CommandContainer
			command :halp do |event|
				event.respond "`COMMANDS:
!week # - info about the week specified
!halp for halp
--TYPE can be 'match' or 'meet'--
!reset <TYPE> - reset confirmations (dont fuck with this or ppl will get angry (like marz))
!getconfirms <TYPE> - see who has and has not confirmed
!confirm <TYPE> <DAY> - confirm attendance to match or meet (DAY NOT NECESSARY FOR MATCH CONFIRM)
!unconfirm <TYPE> - unconfirm attendance to match or meet (bong will get angry here tbh)`

ie.
!confirm meet thursday
!confirm match"
			end
		end
	end
end