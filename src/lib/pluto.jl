"""
    pluto.jl

# Description
This is a set of extensions that are meant to be used in Pluto notebooks and with PlutoUI.
"""

# using LazyModules
# @lazy import Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
# @lazy import PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
using Pluto, PlutoUI

"""
hint(text::String)

Gives a hint
"""
function hint(text::String)
    Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))
end
# hint(text::String) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

"""
confusing_function(text::String, array::Array)

Repeats the `text` as many times as there are elements in `array`.
"""
function keep_working(text=md"The answer is not quite right.")
    Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
end
# keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));

function correct(text=md"Great! You got the right answer! Let's move on to the next section.")
    Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
end
# correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

function almost(text)
    Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
end
# almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))