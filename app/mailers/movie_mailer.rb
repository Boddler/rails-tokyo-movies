class MovieMailer < ApplicationMailer
  default from: "donotreply@tokyo.com"

  def unfound(not_found)
    @not_found = not_found
    admin = ENV["EMAIL"]
    mail(to: admin, subject: "Movies not in TMDB")
  end
end
