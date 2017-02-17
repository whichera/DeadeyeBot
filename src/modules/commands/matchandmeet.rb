require 'pstore'

module Bot
  module DiscordCommands
    module MatchAndMeeting
      extend Discordrb::Commands::CommandContainer
      class Confirm
        def initialize(user_number=nil, discord_name=nil, day=nil)
          @user_number = user_number
          @discord_name = discord_name
          @user_name = data.key(user_number)
          @store = PStore.new('db.pstore')            # match db
          @meetstore = PStore.new('meetstore.pstore') # meet db
          @day = day
          @date = Time.now
        end

        def confirm(type)
          if type.downcase == 'match'
            if confirmed?(type)
              responder(type, 'redundant')
            else
              @store.transaction do 
                @store[@user_name] = 1
              end
              responder(type, 'positive')
            end
          elsif type.downcase == 'meeting' || type.downcase == 'meet'
            if @day == nil
              $response = "Please specify a valid day of the week."
            elsif @day.downcase == 'thursday'
              if confirmed?(type) == 2
                @meetstore.transaction do
                  @meetstore[@user_name] = [2, 1]
                  @meetstore.commit
                end
                responder(type, 'positive')
              elsif confirmed?(type) == 1
                responder(type, 'redundant')
              else
                @meetstore.transaction do
                  @meetstore[@user_name] = [1]
                  @meetstore.commit
                end
                responder(type, 'positive')
              end
            elsif @day.downcase == 'friday'
              if confirmed?(type) == 1
                @meetstore.transaction do
                  @meetstore[@user_name] = [1, 2]
                  @meetstore.commit
                end
                responder(type, 'positive')
              elsif confirmed?(type) == 2
                responder(type, 'redundant')
              else
                @meetstore.transaction do
                  @meetstore[@user_name] = [2]
                  @meetstore.commit
                end
                responder(type, 'positive')
              end
            else
              $response = "Please specify a valid day of the week."
            end
          else
            $response = "Confirm type not recognized. Remember: no commas necessary."
          end
        end

        def unconfirm(type)
          if type.downcase == 'match'
            if confirmed?(type)
              @store.transaction do
                @store[@user_name] = 0
              end
              if @user_number == data[:thebongmastar]
                $response = "#{@discord_name}, you have unconfirmed your attendance for the week. You hate yourself now."
              else
                responder(type, 'negative')
              end
            else
              $response = "#{@discord_name}, you haven't confirmed. Use !confirm to confirm."
            end
          elsif type.downcase == 'meeting' || type.downcase == 'meet'
            if confirmed?(type) == 0
              $response = "You never confirmed for the meeting dude"
            else
              @meetstore.transaction do
                @meetstore[@user_name] = [0]
                @meetstore.commit
              end
              responder(type, 'negative')
            end
          else
            $response = "Input not recognized."
          end
        end

        def confirmed?(type)
          if type.downcase == 'match'
            @store.transaction(true) do
              if @store[@user_name.to_sym] == 1
                return true
              else
                return false
              end
            end
          elsif type.downcase == 'meeting' || type.downcase == 'meet'
            @meetstore.transaction(true) do
              if @meetstore[@user_name.to_sym][0] == 0
                return 0
              elsif @meetstore[@user_name.to_sym][0] == 1
                return 1
              elsif @meetstore[@user_name.to_sym][0] == 2
                return 2
              end
            end
          end
        end

        def responder(type, attribute)
          if attribute == 'positive'
            if type.downcase == 'match'
              $response = "#{@discord_name}, you have confirmed attendance for the match this week."
            elsif type.downcase == 'meeting' || type.downcase == 'meet'
              $response = "#{@discord_name}, you have confirmed availability on #{@day.capitalize} for the meeting."
            end
          elsif attribute == 'redundant'
            if type.downcase == 'match'
              $response = "#{@discord_name}, you already confirmed for the match. Use !unconfirm to unconfirm."
            elsif type.downcase == 'meeting' || type.downcase == 'meet'
              $response = "#{@discord_name}, you already confirmed #{@day.capitalize} for meeting availability."
            end
          elsif attribute == 'negative'
            if type.downcase == 'match'
              $response = "#{@discord_name}, you unconfirmed attendance to the match. Bong hates you now."
            elsif type.downcase == 'meeting' || type.downcase == 'meet'
              $response = "#{@discord_name}, you unconfirmed for the meeting. miss u"
            end
          end
        end

        def getconfirms(type)
          if type.downcase == 'match'
            @confirmed = []
            @unconfirmed = []

            match_confirmations.each do |key, value|
              if value == 0
                @unconfirmed.push(key)
              elsif value == 1
                @confirmed.push(key)
              end
            end

            $response = "Confirmed players: #{@confirmed.map {|name| name.to_s}.join(', ')}
Unconfirmed players: **#{@unconfirmed.map {|name| name.to_s}.join(', ')}**"
          elsif type.downcase == 'meeting' || type.downcase == 'meet'
            @both = []
            @thursday = []
            @friday = []

            meet_confirmations.each do |key, value|
              # if the second integer (meaning there were two confirmations) in the array is equal to 2
              if value[1].to_i > 0
                @both.push(key)
              elsif value[0] == 1
                @thursday.push(key)
              elsif value[0] == 2
                @friday.push(key)
              end
            end

            $response = "**MEETING AVAILABILITY:**
Thursday: #{@thursday.map {|name| name.to_s}.join(', ')}
Friday: #{@friday.map {|name| name.to_s}.join(', ')}
Either: #{@both.map {|name| name.to_s}.join(', ')}"
          else
            $response = "Input type not recognized."
          end
        end

        def info
          if @date.day < 18 # if it's currently before the 18th day of the month
            $response = "The next team meeting is either Thursday, February 16 or Friday the 17th. Please confirm using !meetconfirm <DAY> (ie. !meetconfirm friday)"
          else
            $response = "There is currently no team meeting scheduled."
          end
        end

        def reset(type)
          if type.downcase == 'match'
            @store.transaction do
              @store[:'marz'] = 0
              @store[:'boris'] = 0
              @store[:'karma'] = 0
              @store[:'thebongmastar'] = 0
              @store[:'lucklens'] = 0
              @store[:"Buddha's Buddy"] = 0

              store.commit
            end
            $response = "#{type.capitalize} database has been reset."
          elsif type.downcase == 'meeting' || type.downcase == 'meet'
            @meetstore.transaction do
            @meetstore[:marz] = [0]
            @meetstore[:boris] = [0]
            @meetstore[:karma] = [0]
            @meetstore[:bong] = [0]
            @meetstore[:methodace] = [0]
            @meetstore[:buddha] = [0]

            @meetstore.commit
            end
            $response = "#{type.capitalize} database has been reset."
          else
            $response = "Input type not recognized."
          end
        end

        private

        def data
          {
            marz: 111704402103988224,
            karma: 261688031201722369,
            boris: 129100957811212288,
            thebongmastar: 218315994786037761,
            lucklens: 219762995838844929,
            "Buddha's Buddy": 212673436017754112
          }
        end

        def match_confirmations
          {
            marz: @store.transaction { @store[:marz] },
            boris: @store.transaction { @store[:boris] },
            karma: @store.transaction { @store[:karma] },
            thebongmastar: @store.transaction { @store[:thebongmastar] },
            "Lucklens": @store.transaction { @store[:lucklens] },
            "Buddha's Buddy": @store.transaction { @store[:"Buddha's Buddy"] }
          }
        end

        def meet_confirmations
          {
            marz: @meetstore.transaction { @meetstore[:marz] },
            boris: @meetstore.transaction { @meetstore[:boris] },
            karma: @meetstore.transaction { @meetstore[:karma] },
            thebongmastar: @meetstore.transaction { @meetstore[:bong] },
            "Lucklens": @meetstore.transaction { @meetstore[:methodace] },
            "Buddha's Buddy": @meetstore.transaction { @meetstore[:buddha] }
          }
        end
      end

      command :meeting do |event|
        Confirm.new().info
        event.respond "#{$response}"
      end

      command :reset do |event, type|
        Confirm.new().reset(type)
        event.respond "#{$response}"
      end

      command :confirm do |event, type, day|
        Confirm.new(event.user.id, event.user.name, day).confirm(type)
        event.respond "#{$response}"
      end

      command :unconfirm do |event, type|
        Confirm.new(event.user.id, event.user.name).unconfirm(type)
        event.respond "#{$response}"
      end

      command :getconfirms do |event, type|
        Confirm.new().getconfirms(type)
        event.respond "#{$response}"
      end
    end
  end
end