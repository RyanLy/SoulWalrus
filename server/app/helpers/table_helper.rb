module TableHelper
  
  Aws.use_bundled_cert!
  
  def create_eight_ball_table
    @client = Aws::DynamoDB::Client.new(
      region: 'us-east-1'
    )
    
    table = @client.create_table({
      attribute_definitions: [ # required
        {
          attribute_name: "answer", # required
          attribute_type: "S", # required, accepts S, N, B
        },
      ],
      table_name: "eight_ball", # required
      key_schema: [ # required
        {
          attribute_name: "answer", # required
          key_type: "HASH", # required, accepts HASH, RANGE
        },
      ],
      provisioned_throughput: { # required
        read_capacity_units: 1, # required
        write_capacity_units: 1, # required
      }
    })
  end

  def populate_eight_ball_table
    @client = Aws::DynamoDB::Client.new(
      region: 'us-east-1'
    )
    
    @BALL_ANSWERS = ["It is certain",
      "It is decidedly so",
      "Without a doubt",
      "Yes definitely",
      "You may rely on it",
      "As I see it, yes",
      "Most likely",
      "Outlook good",
      "Yes",
      "Signs point to yes",
      "Reply hazy try again",
      "Ask again later",
      "Better not tell you now",
      "Cannot predict now",
      "Concentrate and ask again",
      "Don't count on it",
      "My reply is no",
      "My sources say no",
      "Outlook not so good",
      "Very doubtful"
    ]

    for @answer in @BALL_ANSWERS
      p @answer
      @client.put_item({
        table_name: "eight_ball", # required
        item: { # required
          "answer" => @answer, # value <Hash,Array,String,Numeric,Boolean,IO,Set,nil>
        }
      })
    end
  end

end
