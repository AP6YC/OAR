"""
    pluto.jl

# Description
This is a set of extensions that are meant to be used in Pluto notebooks and with PlutoUI.
"""

# -----------------------------------------------------------------------------
# DEPENDENCIES
# -----------------------------------------------------------------------------

using Pluto, PlutoUI

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------

const MDString = Markdown.MD

# -----------------------------------------------------------------------------
# COMMON DOCSTRINGS
# -----------------------------------------------------------------------------

const MD_ARG_STRING = """
# Arguments:
- `text::$MDString`: The markdown text to display in the box.
"""

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

"""
Internal wrapper for displaying a markdown admonition.

# Arguments
- `type::String`: the type of admonition.
- `type::String`: the header of the admonition.
- `text::$MDString`: the markdown string to display in the box.
"""
function _admon(type::String, header::String, text::MDString)
    Markdown.MD(Markdown.Admonition(type, header, [text]))
end

"""
Shows a hint box.

$MD_ARG_STRING
"""
function hint(text::MDString)
    _admon("hint", "Hint", text)
end
# hint(text::String) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

"""
Shows an danger box.

$MD_ARG_STRING
"""
function keep_working(text::MDString=md"The answer is not quite right.")
    _admon("danger", "Keep working on it!", text)
end
# keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));

"""
Shows a correct box.

$MD_ARG_STRING
"""
function correct(text::MDString=md"Great! You got the right answer! Let's move on to the next section.")
    _admon("correct", "Got it!", text)
end
# correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

"""
Shows an almost box.

$MD_ARG_STRING
"""
function almost(text::MDString="The answer is almost correct!")
    _admon("warning", "Almost there!", text)
end
# almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))