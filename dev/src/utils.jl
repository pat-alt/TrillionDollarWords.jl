function extract_digits(s::String)
    return match(r"\d*\.?\d+", s).match
end
