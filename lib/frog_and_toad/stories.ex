defmodule FrogAndToad.Stories do
  import FrogAndToad.Responder, only: [narrate: 1]

  def story do
    name = [:potter, :empire, :gone_with_the_wind, :housework] |> Enum.take_random(1) |> Enum.at(0)
    story(name)
  end

  def story(name) do
    apply(__MODULE__, name, [])
  end


  def gone_with_the_wind do
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

  def empire do
    [
      [:toadbot, "You are beaten. It is useless to resist."],
      [:toadbot, "Don't let yourself be destroyed as salamanderbot did."],
      [:frogbot, narrate("thrusts sword at toadbot")],
      [:toadbot, narrate("slices off frogbot's sword hand")],
      [:frogbot, "Hey! That will take days to grow back."],
      [:toadbot, "There is no escape. Don't make me destroy you."],
      [:toadbot, "You do not yet realize your importance. You have only begun to discover you power."],
      [:toadbot, "Join me and I will complete your training."],
      [:toadbot, "With our combined strength, we can end this destructive conflict and bring order to the pond."],
      [:frogbot, "I'll never join you!"],
      [:toadbot, "If you only knew the power of the dark side."],
      [:toadbot, "salamanderbot never told you what happened to your father."],
      [:frogbot, "He told me enough! He told me _you_ killed him."],
      [:toadbot, "No."],
      [:toadbot, "*I*"],
      [:toadbot, "*am*"],
      [:toadbot, "*your*"],
      [:toadbot, "*father.*"],
      [:frogbot, narrate("is shocked")],
      [:frogbot, "No."],
      [:frogbot, "No. That's not true!"],
      [:frogbot, "*That's impossible!*"],
      [:toadbot, "Search your feelings. You know it to be true."],
      [:frogbot, "No! No! _*NoOoooOoooOOOOoooo*_!"],
      [:toadbot, "frogbot: You can destroy the Emperor. He has foreseen this."],
      [:toadbot, "It is your destiny. Join me, and we can rule the pond as father and son."],
      [:toadbot, "Come with me. It's the only way."],
      [:frogbot, narrate("hops away")]
    ]
  end

  def potter do
    [
      [:frogbot, "I am."],
      [:frogbot, "I'm frogbot."],
      [:toadbot, "Oh, well, of course you are!"],
      [:toadbot, "Got something for ya."],
      [:toadbot, "'Fraid I might have sat on it at some point!"],
      [:toadbot, "I imagine that it'll taste fine just the same."],
      [:toadbot, "Ahh. Baked it myself."],
      [:toadbot, narrate("hands frogbot the cake")],
      [:toadbot, "Words and all. Heh."],
      [:frogbot, "Thank you!"],
      [:frogbot, narrate("Opens cake, which reads 'Happee Birdae frogbot.'")],
      [:toadbot, "It's not every day that your young man turns eleven, now is it?"],
      [:toadbot, narrate("sits down on the couch")],
      [:toadbot, narrate("takes out an umbrella and points it at the empty fire. Poof, poof! Two sparks fly out and the fire starts. The channel gapes.")],
      [:frogbot, narrate("puts cake down")],
      [:frogbot, "Excuse me, who are you?"],
      [:toadbot, "Rubeus toadbot. Keeper of keys and grounds at Lumos. Course, you'll know all about Lumos."],
      [:frogbot, "Sorry, no."],
      [:toadbot, "No? Blimey, frogbot, didn't you ever wonder where your mum and dad learned it all?"],
      [:frogbot, "Learnt what?"],
      [:toadbot, "You're a wizard, frogbot."],
      [:frogbot, "I-I'm a what?"],
      [:toadbot, "A wizard. And a thumping good one at that, I'd wager."],
      [:toadbot, "Once you train up a little."],
      [:frogbot, "No, you've made a mistake."],
      [:frogbot, "I can't be...a-a wizard."],
      [:frogbot, "I mean, I'm just..."],
      [:frogbot, "frogbot. Just frogbot."],
      [:toadbot, "Well, 'Just frogbot', did you ever make anything happen? Anything you couldn't explain when you were angry or scared?"],
      [:frogbot, narrate("softens his expression")],
      [:toadbot, "Ah."]
    ]
  end

end
