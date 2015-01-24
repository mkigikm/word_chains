#!/usr/bin/env ruby

require 'set'

class WordChainer
  attr_reader :source, :target

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

  def tree
    @visited_words.keys.map do |word|
      [word, find_path(word).count - 1]
    end
  end

  def find_path(target=nil)
    target = @target if target.nil?
    raise "ArgumentError" if target.nil?

    return nil unless @visited_words.keys.include?(target)

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
end

if __FILE__ == $PROGRAM_NAME
  require 'getoptlong'

  def usage_message
    usage_message = <<EOF
usage: #{$PROGRAM_NAME} [-d DICTIONARY_FILE] <source> [<target>]
EOF
    puts usage_message
    exit
  end

  def print_path(chainer, target=nil)
    target = chainer.target if target.nil?
    path = chainer.find_path(target)

    if path.nil?
      puts "#{chainer.source} doesn't lead to #{target}"
    else
      chainer.find_path(target).each do |word|
        puts word
      end
    end

    nil
  end

  def print_tree(chainer)
    chainer.tree.each do |node|
      puts "#{node.first} (#{node.last})"
    end
  end

  opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--dictionary', '-d', GetoptLong::REQUIRED_ARGUMENT],
    ['--tree', '-t', GetoptLong::NO_ARGUMENT]
  )
  dictionary_file = WordChainer::DEFAULT_DICTIONARY
  show_tree = false

  opts.each do |opt, arg|
    case opt
    when '--help'
      puts usage_message
      exit
    when '--dictionary'
      dictionary_file = arg
    when '--tree'
      show_tree = true
    end
  end

  if ARGV.count == 0
    puts usage_message
    exit
  end

  chainer = WordChainer.new(dictionary_file)

  chainer.build_tree(ARGV.shift, ARGV.shift)

  if show_tree
    print_tree(chainer)
  end

  # command line mode
  if chainer.target
    print_path(chainer)

  else # interactive mode
    while true
      print "find path from #{chainer.target} to: "
      target = gets

      if target.nil? # EOF
        puts
        exit
      end

      print_path(chainer, target.chomp)
    end
  end
end
