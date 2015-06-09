require 'uri'

class ApplicationMailer < ActionMailer::Base

  default :from => Setting[:email_reply_address] || "noreply@satellite.example.org"

  def mail(headers = {}, &block)
    if headers.present?
      headers[:subject] = "#{Setting[:email_subject_prefix]} #{headers[:subject]}" if (headers[:subject] && !Setting[:email_subject_prefix].blank?)
      headers['X-Foreman-Server'] = URI.parse(Setting[:foreman_url]).host unless Setting[:foreman_url].blank?
    end
    super
  end

  private

  class GroupMail
    def initialize(emails)
      ActiveSupport::Deprecation.warn 'GroupMail will be removed as mailers should not generate multiple messages, use MailNotification#deliver'
      @emails = emails
    end

    def deliver
      @emails.each do |email|
        begin
          email.deliver
        rescue => e
          Rails.logger.info("Unable to send mail notification: #{e}")
        end
      end
    end
  end

  def group_mail(users, options)
    ActiveSupport::Deprecation.warn '#group_mail is replaced by MailNotification#deliver with :users in the options hash, this does not function properly'

    mails = users.map do |user|
      @user = user
      set_locale_for user
      mail(options.merge(:to => user.mail)) unless user.mail.blank?
    end

    GroupMail.new(mails.compact)
  end

  def set_locale_for(user)
    old_loc = FastGettext.locale
    begin
      FastGettext.set_locale(user.locale.blank? ? 'en' : user.locale)
      yield if block_given?
    ensure
      FastGettext.locale = old_loc if block_given?
    end
  end
end
