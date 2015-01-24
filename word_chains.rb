#!/usr/bin/env ruby

require 'set'

class WordChainer
  SYSTEM_DICTIONARY = "/usr/share/dict/words"
  DEFAULT_DICTIONARY = "./dictionary.txt"

  def initialize(dictionary_filename)
    init_dictionary(dictionary_filename)
    @visited_words = {}
  end

  def self.system_dictionary
    WordChainer.new(SYSTEM_DICTIONARY)
  end

  def self.default_dictionary
    WordChainer.new(DEFAULT_DICTIONARY)
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
                                                valid_word?(target)

    init_tree(source, target)
    @queue = [source]
    until @queue.empty? || @visited_words.keys.include?(@target)
      explore_word(@queue.shift)
    end
  end

  def find_path(target=nil)
    target = @target if target.nil?
    raise "ArgumentError" if target.nil?

    [].tap do |path|
      current = target
      until current.nil?
        path.unshift(current)
        current = @visited_words[current]
      end
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
    @visited_words = {source => nil}
    @source = source
    @target = target
  end

  def explore_word(current_word)
    adjacent_words(current_word).each do |candidate|
      #skip words we already have a path to
      next if @visited_words.keys.include?(candidate)

      @visited_words[candidate] = current_word

      #don't need to continue if we've reached the target
      return if candidate == @target

      #otherwise add the candidate to the queue
      @queue << candidate
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  chainer = WordChainer.default_dictionary
  chainer.build_tree(ARGV.shift, ARGV.shift)
  chainer.find_path.each do |word|
    puts word
  end
end
