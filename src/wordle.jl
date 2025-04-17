module wordle

using JSON3

export process_wordlist, make_every_word_vector, cleanword, compare_strings, check_input_letters, check_word_for_validity, input_trial, input_game_variant, get_color_dict, colorize_string, get_colorized_string_vector, intro

function intro(feedback_colors_dict::Dict)

	colors = get_color_dict()
	# Lese den Inhalt der Datei "data/raw/title.txt"
	file_path = "data/raw/title.txt"
	title = open(file_path, "r") do file
		read(file, String)
	end
	title = colorize_string(title, colors, "lightblue")
	# Gib den Inhalt der Datei auf dem Bildschirm aus

	rand = 5
	println("\n"^10)
	println(title)
	println("\e[37m")
	println("\n"^10)
	println(" "^rand, "Willkommen bei Wördle!")
	println(" "^rand, "In diesem Spiel geht es darum, ein zufälliges Wort zu erraten.")
	println(" "^rand, "Das Wort hat eine Länge von 5 Buchstaben.")
	println(" "^rand, "Du hast 6 Versuche, um das Wort zu erraten.")
	println(" "^rand, "Nach jedem Versuch erhältst du ein Feedback, wie viele Buchstaben")
	println(" "^rand, "des eingegebenen Wortes im gesuchten Wort enthalten sind.")
	println(" "^rand, "$(colors[feedback_colors_dict[right]])Grün\e[37m bedeutet, dass der Buchstabe an der richtigen Stelle steht.")
	println(" "^rand, "Gelb bedeutet, dass der Buchstabe im gesuchten Wort enthalten ist,")
	println(" "^rand, "aber an einer anderen Stelle.")
	println(" "^rand, "Weiß bedeutet, dass der Buchstabe nicht im gesuchten Wort enthalten ist.")
	println(" "^rand, "Viel Spaß!")
	println("\n", " "^rand, "Drücke Enter, um fortzufahren...")
	readline()
end


function process_wordlist(input_path::String, output_path::String)
	# Lese die JSON-Datei als Byte-Array ein
	file = open(input_path, "r")
	data = read(file)
	close(file)

	# Konvertiere die Byte-Daten in einen String mit UTF-8 Encoding
	content = String(data)

	# Parse den JSON-Inhalt
	words = JSON3.read(content)

	# Wandle die Strings in Kleinbuchstaben um, bereinige sie und schreibe sie in ein Set
	word_set = Set{String}(cleanword(lowercase(word)) for word in words)

	# Wandle das Set wieder in einen Vektor um und sortiere ihn
	word_vector = sort(collect(word_set))

	# Schreibe den sortierten Vektor in die neue JSON-Datei
	open(output_path, "w") do file
		JSON3.write(file, word_vector)
	end
end

function make_every_word_vector(json_path::String)
	file = open(json_path, "r")
	words = JSON3.read(file)
	close(file)

	# Alle Wörter ohne Filter zurückgeben
	word_vector = collect(words)

	return word_vector
end

function cleanword(input::AbstractString)
	changetable = Dict(
		'á' => 'a', 'à' => 'a', 'â' => 'a', 'ã' => 'a', 'å' => 'a',
		'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
		'í' => 'i', 'ì' => 'i', 'î' => 'i', 'ï' => 'i',
		'ó' => 'o', 'ò' => 'o', 'ô' => 'o', 'õ' => 'o', 'ø' => 'o',
		'ú' => 'u', 'ù' => 'u', 'û' => 'u',
		'ç' => 'c',
		'ñ' => 'n', 'Ñ' => 'N'
	)

	output = ""
	for char in input
		output *= haskey(changetable, char) ? changetable[char] : char
	end
	return output
end


function compare_strings(word_to_guess::String, trial_string::String)
	goal_word = cleanword(lowercase(word_to_guess))
	trial_word = cleanword(lowercase(trial_string))
	goal_letter_vector = collect(goal_word)
	trial_letter_vector = collect(trial_word)
	available_goal_vector = fill("available", length(trial_letter_vector))
	progress_vector = fill("wrong", length(trial_letter_vector))

	# Check for right letters at the right position
	for trial_position ∈ eachindex(trial_letter_vector)
		if trial_letter_vector[trial_position] == goal_letter_vector[trial_position]
			available_goal_vector[trial_position] = "not_available"
			progress_vector[trial_position] = "right"
		end
	end
	# Check for right letters at the wrong position
	for trial_position ∈ eachindex(trial_letter_vector)
		for goal_position ∈ eachindex(goal_letter_vector)
			is_wrong_position = available_goal_vector[goal_position] == "available" && goal_letter_vector[goal_position] == trial_letter_vector[trial_position]
			if is_wrong_position
				available_goal_vector[goal_position] = "not_available"
				progress_vector[trial_position] = "wrong_position"
				break
			end
		end
	end

	return progress_vector
end

function check_input_letters(word::String, length_word)::Bool
	word = replace(word, r"\s+" => "")
	if length(word) != length_word
		return false
	end

	if !all(typeof(c) == Char && ('a' <= c <= 'z' || 'A' <= c <= 'Z' || c in "äöüßÄÖÜ") for c in word)
		return false
	end

	return true
end



function input_trial(word_vector::Vector{String}, word_length::Int)::String
	word_trial = ""
	while true
		word_trial = lowercase(cleanword(readline()))
		if word_trial ∈ word_vector
			return word_trial
		else
			println("Netter Versuch, aber das ist kein deutsches Wort mit fünf Buchstaben!")
		end
	end


end

function get_color_dict()
	farben = Dict(
		"red" => "\e[31m",
		"green" => "\e[32m",
		"yellow" => "\e[33m",
		"blue" => "\e[34m",
		"purple" => "\e[35m",
		"lightblue" => "\e[36m",
		"white" => "\e[37m",
		"lightred" => "\e[91m",
		"green2" => "\e[92m",
		"lightyellow" => "\e[93m",
		"lightpurple" => "\e[95m",
		"cyan" => "\e[96m"
	)
	return farben
end

function colorize_string(text::String, color_dict::Dict{String, String}, color::String)::String
	_colored_string = color_dict["$color"] * text * "\e[0m"
	return _colored_string
end

function get_colorized_string_vector(word::String, progress::Vector{String}, color_dict::Dict)::Vector{String}
	word_string_vector = [string(c) for c in collect(word)]
	colorized_string_vector = Vector{String}([])
	for i ∈ eachindex(word_string_vector)
		if progress[i] == "right"
			colorized_string = colorize_string(word_string_vector[i], color_dict, "green2")
		elseif progress[i] == "wrong_position"
			colorized_string = colorize_string(word_string_vector[i], color_dict, "red")
		else
			colorized_string = colorize_string(word_string_vector[i], color_dict, "white")
		end
		push!(colorized_string_vector, colorized_string)
	end
	return colorized_string_vector

end



end # module wordle

