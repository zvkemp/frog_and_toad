defmodule FrogAndToad.Stories do
  import FrogAndToad.Responder, only: [narrate: 1]

  def story do
    name = [:casablanca, :housework] |> Enum.take_random(1) |> Enum.at(0)
    story(name)
  end

  def story(name) do
    apply(__MODULE__, name, [])
  end


  def casablanca do
    [
      [:frogbot, " Oh, toadbot, toadbot please don't say that. I'm so sorry, I'm so sorry for everything. "],
      [:toadbot, " My darling, you're such a child. You think that by saying, I'm sorry, all the past can be corrected. Here, take my handkerchief. Never, at any crisis of your life, have I known you to have a handkerchief. "],
      [:frogbot, " toadbot! toadbot, where are you going? "],
      [:toadbot, " I'm going back to Charleston, back where I belong. "],
      [:frogbot, " Please, please take me with you! "],
      [:toadbot, " No, I'm through with everything here. I want peace. I want to see if somewhere there isn't something left in life of charm and grace. Do you know what I'm talking about? "],
      [:frogbot, " No, I only know that I love you. "],
      [:toadbot, " That's your misfortune. "],
      [:frogbot, " Oh, toadbot toadbot toadbot, toadbot...toadbot if you go, where shall I go, what shall I do? "],
      [:toadbot, " Frankly my dear, I don't give a damn."]
    ]
  end

  def housework do
    [
      [:toadbot, narrate("wakes up")],
      [:toadbot, "Drat!"],
      [:toadbot, "This house is a mess. I have so much work to do."],
      [:frogbot, narrate "looks through the window"],
      [:frogbot, "toadbot, you are right."],
      [:frogbot, "It is a mess."],
      [:toadbot, narrate "pulls the covers over his head"],
      [:toadbot, "I will do it tomorrow."],
      [:toadbot, "Today I will take life easy."],
      [:frogbot, narrate "comes into the house"],
      [:frogbot, "toadbot, your pants and jacket are lying on the floor."],
      [:toadbot, "_(from under the covers)_ Tomorrow."],
      [:frogbot, "Your kitchen sink is filled with dirty dishes."],
      [:toadbot, "Tomorrow."],
      [:frogbot, "There is dust on your chairs."],
      [:toadbot, "Tomorrow."],
      [:frogbot, "Your windows need scrubbing."],
      [:frogbot, "Your plants need watering."],
      [:toadbot, "_*Tomorrow!*_"],
      [:toadbot, "_*I will do it all tomorrow!*_"],
      [:toadbot, narrate "sits on the edge of his bed"],
      [:toadbot, "Blah." ],
      [:toadbot, "I feel down in the dumps."],
      [:frogbot, "Why?"],
      [:toadbot, "I am thinking about tomorrow." ],
      [:toadbot, "I am thinking about all of the many things that I will have to do."],
      [:frogbot, "Yes, tomorrow will be a very hard day for you."],
      [:toadbot, "But frogbot, if I pick up my pants and jacket right now, then I will not have to pick them up tomorrow, will I?"],
      [:frogbot, "No. You will not have to."],
      [:toadbot, narrate "picks up his clothes"],
      [:toadbot, narrate "puts them in the closet"],
      [:toadbot, "frogbot, if I wash my dishes right now then I will not have to wash them tomorrow, will I?"],
      [:frogbot, "No. You will not have to."],
      [:toadbot, narrate "washes and dries his dishes."],
      [:toadbot, narrate "puts them in the cupboard"],
      [:toadbot, "frogbot, if I dust my chairs and scrub my windows and water my plants right now, then I will not have to do it tomorrow, will I?"],
      [:frogbot, "No, you will not have to do any of it."],
      [:toadbot, narrate "dusts his chairs"],
      [:toadbot, narrate "scrubs his windows"],
      [:toadbot, narrate "waters his plants"],
      [:toadbot, "There. Now I feel better."],
      [:toadbot, "I am not in the dumps anymore."],
      [:frogbot, "Why?"],
      [:toadbot, "Because I have done all that work." ],
      [:toadbot, "Now I can save tomorrow for something that I really want to do."],
      [:frogbot, "What is that?"],
      [:toadbot, "Tomorrow, I can just take life easy."],
      [:toadbot, narrate "goes back to bed"],
      [:toadbot, narrate "pulls the covers over his head and falls asleep"]
    ]
  end
end
