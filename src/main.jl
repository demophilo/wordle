using JSON3
include("wordle.jl")
using .wordle

feedback_colors_dict = Dict(
    "right" => "green",
    "wrong_position" => "yellow",
    "wrong" => "red"
)

intro(feedback_colors_dict)
