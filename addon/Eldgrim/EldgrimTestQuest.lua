-- A test quest for the hearth board, set by Eldgrim. It shows only on Jasmine
-- Amberbrew's client, is never sent to anyone, and Eldgrim confirms it the
-- moment it is marked complete. Change the id to test it again from the start.
-- Set quest to nil to remove it. mode is "one" (the first to accept takes it
-- off the board) or "all" (each member may complete it once).

EldgrimTestQuestFile = {
    quest = {
        id = "Eldgrim#test-lantern-1",
        mode = "one",
        title = "The Lantern That Forgot Its Name",
        story = "One of the lanterns along the road has stopped answering to its name. It still burns, mind you. It only sulks, the way lanterns do when nobody has spoken to them in a long while. Find one that hangs where travelers pass, and keep it company until it feels remembered. Then give it a new name, something warm, something it would be proud to answer to.",
        objective = "Find a lantern along a road, stand beside it for a full minute, and give it a new name in /say.",
    },
}
