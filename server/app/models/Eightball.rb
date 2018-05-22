class Eightball
  include Dynamoid::Document

  table :name => :eight_ball_answers, :key => :answer

  field :answer
  field :status
  
  @@DEFAULT_BALL_ANSWERS = [
    ['It is certain', 'POSITIVE'],
    ['It is decidedly so', 'POSITIVE'],
    ['Without a doubt', 'POSITIVE'],
    ['Yes definitely', 'POSITIVE'],
    ['You may rely on it', 'POSITIVE'],
    ['As I see it, yes', 'POSITIVE'],
    ['Most likely', 'POSITIVE'],
    ['Outlook good', 'POSITIVE'],
    ['Yes', 'POSITIVE'],
    ['Signs point to yes', 'POSITIVE'],
    ['Reply hazy try again', 'NEUTRAL'],
    ['Ask again later', 'NEUTRAL'],
    ['Better not tell you now', 'NEUTRAL'],
    ['Cannot predict now', 'NEUTRAL'],
    ['Concentrate and ask again', 'NEUTRAL'],
    ['Don\'t count on it', 'NEGATIVE'],
    ['My reply is no', 'NEGATIVE'],
    ['My sources say no', 'NEGATIVE'],
    ['Outlook not so good', 'NEGATIVE'],
    ['Very doubtful', 'NEGATIVE']
  ]
  
  def self.loadAnswers
    if Eightball.all.to_a.empty?
      for @answer, @status in @@DEFAULT_BALL_ANSWERS
        p @answer
        p @status
        Eightball.new(
          :answer => @answer,
          :status => @status
        ).save
      end
    end
  end
  
end
