Rubytime::DATE_FORMATS.each do |name, data|
  Date::DATE_FORMATS[name] = data[:format]
end
