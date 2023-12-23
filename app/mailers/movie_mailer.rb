class MovieMailer < ApplicationMailer
  default from: "donotreply@tokyo.com"

  def unfound
    admin = ENV["EMAIL"]
    mail(to: admin, subject: "Movies not in TMDB")
  end
end
