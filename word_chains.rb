class WordChainer
  def initialize(dictionary_filename)
    init_dictionary(dictionary_filename)
  end

  private
  def init_dictionary(dictionary_filename)
    @dictionary = File.readlines(dictionary_filename).map(&:chomp)
  end
end
