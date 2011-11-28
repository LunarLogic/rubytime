class DataMapper::Validate::ValidationErrors
  def to_json
    @errors.to_json
  end
end
