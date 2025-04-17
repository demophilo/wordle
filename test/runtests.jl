using Test
using JSON3
include("../src/wordle.jl")
using .wordle

@testset "make_every_word_vector" begin
	word_vector = make_every_word_vector("../data/raw/wortliste.json")
	@test "tanne" ∈ word_vector
	@test "tante" ∈ word_vector
	@test "zinn" ∉ word_vector
	@test "zahn" ∉ word_vector
	@test "zihn" ∉ word_vector
	@test "zinnn" ∉ word_vector
	@test "ziehn" ∉ word_vector
	@test "zähne" ∈ word_vector

end

@testset "cleanword" begin
	@test cleanword("áéíóú") == "aeiou"
	@test cleanword("àèìòù") == "aeiou"
	@test cleanword("âêîôû") == "aeiou"
	@test cleanword("ãõ") == "ao"
	@test cleanword("å") == "a"
	@test cleanword("äëïöü") == "äeiöü"
	@test cleanword("ç") == "c"
	@test cleanword("ñ") == "n"
	@test cleanword("Ñ") == "N"
end

@testset "compare_strings" begin
	@test compare_strings("zinne", "zinne") == ["right", "right", "right", "right", "right"]
	@test compare_strings("zinne", "tinne") == ["wrong", "right", "right", "right", "right"]
	@test compare_strings("zinne", "nnnie") == ["wrong_position", "wrong", "right", "wrong_position", "right"]
	@test compare_strings("zinne", "xarrs") == ["wrong", "wrong", "wrong", "wrong", "wrong"]
	@test compare_strings("zinne", "eggau") == ["wrong_position", "wrong", "wrong", "wrong", "wrong"]
	@test compare_strings("zinne", "zinnn") == ["right", "right", "right", "right", "wrong"]
	@test compare_strings("zünne", "zinnn") == ["right", "wrong", "right", "right", "wrong"]
	@test compare_strings("tanne", "netan") == ["wrong_position", "wrong_position", "wrong_position", "wrong_position", "wrong_position"]
end

@testset "check_input_letters" begin
	@test check_input_letters("zinne", 5) == true
	@test check_input_letters("zinn", 5) == false
	@test check_input_letters("zin nn", 5) == true
	@test check_input_letters("üöÄäß", 5) == true
end

@testset "get_color_dict" begin
	color_dict = get_color_dict()

	@test color_dict["red"] == "\e[31m"
	@test color_dict["green"] == "\e[32m"
	@test color_dict["yellow"] == "\e[33m"
	@test color_dict["blue"] == "\e[34m"
	@test color_dict["purple"] == "\e[35m"
	@test color_dict["lightblue"] == "\e[36m"
	@test color_dict["white"] == "\e[37m"
	@test color_dict["lightred"] == "\e[91m"
	@test color_dict["green2"] == "\e[92m"
	@test color_dict["lightyellow"] == "\e[93m"
	@test color_dict["lightpurple"] == "\e[95m"
	@test color_dict["cyan"] == "\e[96m"
end

@testset "colorize_string" begin
	color_dict = get_color_dict()
	colored_string = colorize_string("Hello World!", color_dict, "red")

	@test colored_string == "\e[31mHello World!\e[0m"
end
