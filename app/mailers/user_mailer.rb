class UserMailer < ActionMailer::Base
    default from: "Mindfuse.io <scox@mindfuse.io>"

    def signup_email(user)
        @user = user
        @twitter_message = "Get industry grants and collaboration opportunities direct to your inbox. Excited for @mindfuseio to launch!"

        mail(:to => user.email, :subject => "Thanks for signing up!")
    end
end
