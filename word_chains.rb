require 'set'

class WordChainer
  SYSTEM_DICTIONARY = "/usr/share/dict/words"

  def initialize(dictionary_filename)
    init_dictionary(dictionary_filename)
    @visited_words = {}
  end

  def self.system_dictionary
    WordChainer.new(SYSTEM_DICTIONARY)
  end

  def adjacent_words(word)
    adjacent_words_switch_one(word).concat(
      adjacent_words_del_one(word)).concat(
      adjacent_words_add_one(word))
  end

  def adjacent_words_switch_one(word)
    [].tap do |adjacents|
      word.length.times do |i|
        ('a'..'z').each do |letter|
          next if word[i] == letter

          candidate = word.dup
          candidate[i] = letter
          adjacents << candidate if valid_word?(candidate)
        end
      end
    end
  end

  def adjacent_words_del_one(word)
    [].tap do |adjacents|
      word.length.times do |i|
        candidate = word.dup
        candidate[i] = ""
        adjacents << candidate if valid_word?(candidate)
      end
    end
  end

  def adjacent_words_add_one(word)
    [].tap do |adjacents|
      (word.length + 1).times do |i|
        ('a'..'z').each do |letter|
          candidate = word.dup
          candidate.insert(i, letter)
          adjacents << candidate if valid_word?(candidate)
        end
      end
    end
  end

  def build_tree(source, target=nil)
    raise "#{source} not in dictionary" unless valid_word?(source)
    raise "#{target} not in dictionary" unless target.nil? ||
                                                valid_word(target)

    init_tree(source, target)
    @queue = [source]
    until @queue.empty?
      explore_word(@queue.shift)
    end
  end

  private
  def init_dictionary(dictionary_filename)
    @dictionary = Set.new(File.readlines(dictionary_filename).map(&:chomp))
  end

  def valid_word?(word)
    @dictionary.include?(word)
  end

  def init_tree(source, target)
    @visited_words = {}
    @source = source
    @target = target
  end
end
